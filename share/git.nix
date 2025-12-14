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
    };
    pull = {
      rebase = true;
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
  };
  includes = [
    {
      path = "~/.gitconfig";
    }
  ];
}
