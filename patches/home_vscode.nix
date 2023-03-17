{
    home = {
      activation = {
        afterWriteBoundary = {
          after = [ "writeBoundary" ];
          before = [ ];
          data = ''
            find ~/.config/Code | while read -r path
            do
              $DRY_RUN_CMD chmod --recursive +w \
                "$(readlink --canonicalize "$path")"
            done
          '';
        };
      };
  };
}