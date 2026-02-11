{
  enable = true;
  ignores = [
    "**/.totto/"
    "**/.serena/"
    "**/.DS_Store"
    "**/env*"
    "!**/env*.template"
    "**/*.local*"
    "!**/*.local.template*"
  ];
  settings = {
    user = {
      name = "totto2727";
      email = "kaihatu.totto2727@gmail.com";
      signingKey = "BA662CD23E2B4AD8";
    };
    pull = {
      rebase = true;
      autostash = true;
    };
    core = {
      ignorecase = false;
    };
    init = {
      defaultBranch = "main";
    };
    merge = {
      conflictstyle = "zdiff3";
    };
    commit = {
      gpgsign = true;
    };
    alias = {
      unstage = "reset --mixed";
      undo = "reset --mixed HEAD^";
    };
    merge = {
      tool = "vimdiff";
      algorithm = "histogram";
    };
  };
  includes = [
    {
      path = "~/.gitconfig";
    }
  ];
}
