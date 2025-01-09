{...}: {
  editorconfig = {
    enable = false;
    settings = {
      "*" = {
        charset = "utf-8";
        end_of_line = "lf";
        indent_size = 2;
        indent_style = "space";
        insert_final_newline = true;
        trim_trailing_whitespace = true;
        tab_width = 2;
      };
      "*.{bat,cmd,ps1}" = {
        end_of_line = "crlf";
      };
      "*.{py,rs}" = {
        indent_size = 4;
        tab_width = 4;
      };
      "{.{go,tsv},go.{mod,sum},Makefile}" = {
        indent_size = 4;
        indent_style = "tab";
        tab_width = 4;
      };
      "*.{md,mdx}" = {
        trim_trailing_whitespace = false;
      };
    };
  };
}
