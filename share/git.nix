{
  enable = true;
  ignores = [
    "**/.totto/"
    "**/.DS_Store"
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
