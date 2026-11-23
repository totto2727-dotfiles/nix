{ pkgs, pass-cli }:

let
  inherit (pkgs) fetchurl stdenvNoCC writeShellScriptBin;

  oo-cli = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "oo-cli";
    version = "1.9.8";
    src = fetchurl {
      url = "https://registry.npmjs.org/@oomol-lab/oo-cli-darwin-arm64/-/oo-cli-darwin-arm64-${finalAttrs.version}.tgz";
      hash = "sha512-xxuqBb/frLhmCK7lQzVF83oHTiMv/oXiOe/gTuwoDT28q6mB8tFnjvVKfD6Ew9+h+kp5ADznT0+nmLTNu0PBAA==";
    };
    dontBuild = true;
    dontStrip = true;
    installPhase = ''
      runHook preInstall
      install -Dm755 bin/oo "$out/bin/oo"
      runHook postInstall
    '';
  });

  monid-cli = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "monid-cli";
    version = "0.1.7";
    src = fetchurl {
      url = "https://registry.npmjs.org/@monid-ai/cli/-/cli-${finalAttrs.version}.tgz";
      hash = "sha512-ExBDCMEavydx7O7Nqcjo25sWvHoxCbM+TuluzfM4pKvQtZfCpzSI+zuUDcMCCdeglvPbxLu/tDCNmdUG/7pcUw==";
    };
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      install -Dm644 dist/index.js "$out/dist/index.js"
      install -Dm644 package.json "$out/package.json"
      runHook postInstall
    '';
  });

  openConnector = ''
    set +x
    set -eu

    read_connector_value() {
      local value
      if ! value="$(
        ${pass-cli}/bin/pass-cli --offline get "$1" --quiet --no-clipboard --field password </dev/null 2>/dev/null
      )" || [[ -z "$value" ]]; then
        printf 'Could not read %s from the guest Pass CLI vault without prompting.\n' "$1" >&2
        return 1
      fi
      printf '%s' "$value"
    }

    connector_url="$(read_connector_value open-connector/url)"
    connector_token="$(read_connector_value open-connector/api-key)"
  '';

  oo = writeShellScriptBin "oo" ''
    ${openConnector}
    export OO_CONNECTOR_URL="$connector_url"
    export OO_CONNECTOR_TOKEN="$connector_token"
    exec ${oo-cli}/bin/oo "$@"
  '';

  monid = writeShellScriptBin "monid" ''
    ${openConnector}
    umask 077
    config_root="$(${pkgs.coreutils}/bin/mktemp -d "''${TMPDIR:-/tmp}/monid-gateway.XXXXXX")"
    trap '${pkgs.coreutils}/bin/rm -rf -- "$config_root"' EXIT
    trap 'exit 129' HUP
    trap 'exit 130' INT
    trap 'exit 143' TERM

    export XDG_CONFIG_HOME="$config_root"
    export MONID_API_BASE_URL="''${connector_url%/}/v1/passthrough/monid"
    ${pkgs.coreutils}/bin/mkdir "$XDG_CONFIG_HOME/monid"
    ${pkgs.jq}/bin/jq -n '{active_key: "gateway", last_update_check: (now | todate)}' > "$XDG_CONFIG_HOME/monid/config.yaml"
    OPENCONNECTOR_TOKEN="$connector_token" ${pkgs.jq}/bin/jq -n \
      '{keys: {gateway: {key: env.OPENCONNECTOR_TOKEN, prefix: "gateway", added_at: (now | todate)}}}' \
      > "$XDG_CONFIG_HOME/monid/credentials.yaml"

    ${pkgs.nodejs-slim}/bin/node ${monid-cli}/dist/index.js "$@"
  '';
in
[
  oo
  monid
]
