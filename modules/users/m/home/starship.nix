{ ... }:

{
  programs.starship = {
    enable = true;

    settings = {
      add_newline = false;

      aws.disabled = true;
      azure.disabled = true;

      battery.disabled = true;

      character = {
        error_symbol = "[✗](bold #E78284)";
        success_symbol = "[❯](bold #EA999C)";
        vimcmd_symbol = "[❮](bold #A6D189)";
      };

      cmd_duration = {
        format = "took [$duration](bold #E5C890) ";
        min_time = 2000;
      };

      directory = {
        read_only_style = "#E78284";
        repo_root_style = "bold #EA999C";
        style = "bold #C6D0F5";
        truncate_to_repo = true;
        truncation_length = 3;
        truncation_symbol = "…/";
      };

      docker_context = {
        format = "via [$symbol$context]($style) ";
        style = "#949CBB";
        symbol = " ";
      };

      gcloud.disabled = true;

      git_branch = {
        format = "on [$symbol$branch]($style) ";
        style = "#F4B8E4";
        symbol = "";
      };

      git_status = {
        ahead = "[⇡\${count}](#EF9F76) ";
        behind = "[⇣\${count}](#E5C890) ";
        conflicted = "[=\${count}](#E78284) ";
        deleted = "[✘\${count}](#E78284) ";
        diverged = "[⇕⇡\${ahead_count}⇣\${behind_count}](#EF9F76) ";
        format = "($all_status$ahead_behind)";
        modified = "[!\${count}](#E5C890) ";
        renamed = "[»\${count}](#F4B8E4) ";
        staged = "[+\${count}](#EF9F76) ";
        stashed = ''[\$''${count}](#949CBB) '';
        untracked = "[?\${count}](#949CBB) ";
      };

      golang = {
        format = "via [$symbol$version]($style) ";
        style = "#F2D5CF";
        symbol = "";
      };

      memory_usage.disabled = true;

      nix_shell = {
        format = ''via [$symbol$state( \($name\))](bold #C6D0F5) '';
        heuristic = true;
        symbol = "❄ ";
      };

      nodejs = {
        format = "via [$symbol$version]($style) ";
        style = "#A6D189";
        symbol = "";
      };

      package.disabled = true;

      python = {
        format = "via [$symbol$version]($style) ";
        style = "#E5C890";
        symbol = "";
      };

      rust = {
        format = "via [$symbol$version]($style) ";
        style = "#EF9F76";
        symbol = "";
      };
    };
  };
}
