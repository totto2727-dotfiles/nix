{
  enable = true;
  ignores = [
    "**/.totto/"
    "**/.DS_Store"
    "**/*.local*"
    "!**/*.local.template*"
  ];
  settings = {
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
