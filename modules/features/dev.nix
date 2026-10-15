{ inputs, ... }: {
  flake.nixosModules.dev = { config, pkgs, ... }:
    let
      jtsCore = pkgs.fetchurl {
        url = "https://repo1.maven.org/maven2/org/locationtech/jts/jts-core/1.19.0/jts-core-1.19.0.jar";
        hash = "sha256-27hkTPMkEj0GwnqpgvVwgR4QtMsfKu+JOwDeI30z78A=";
      };
    in
    {
      users.users.${config.my.user}.extraGroups = [ "docker" ];

      virtualisation.docker.enable = true;

      systemd.services.docker-image-prune = {
        description = "Prune dangling docker images";
        after = [ "docker.service" ];
        requires = [ "docker.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${config.virtualisation.docker.package}/bin/docker image prune -f";
        };
        startAt = "weekly";
      };
      systemd.timers.docker-image-prune.timerConfig.Persistent = true;

      # Dev services. Units run with --rm, so anything worth keeping needs a
      # volume. Ports bind to localhost because Docker bypasses the firewall.
      virtualisation.oci-containers = {
        backend = "docker";
        containers = {
          pg18 = {
            image = "pgvector/pgvector:pg18";
            ports = [ "127.0.0.1:5432:5432" ];
            environment = {
              POSTGRES_USER = "root";
              POSTGRES_PASSWORD = "root";
            };
            volumes = [ "pg18-data:/var/lib/postgresql" ];
          };
          smtp4dev = {
            image = "rnwood/smtp4dev";
            ports = [ "127.0.0.1:1025:25" "127.0.0.1:5001:80" ];
          };
          redis8 = {
            image = "redis:8";
            ports = [ "127.0.0.1:6379:6379" ];
            volumes = [ "redis8-data:/data" ];
          };
          solr9 = {
            image = "solr:9";
            ports = [ "127.0.0.1:8983:8983" ];
            volumes = [
              "solr9-data:/var/solr"
              # JTS for the spatial field types (ckanext-spatial). The image only
              # ships it in the sql module, off the webapp classpath.
              "${jtsCore}:/opt/solr/server/solr-webapp/webapp/WEB-INF/lib/${jtsCore.name}:ro"
            ];
          };
          silo = {
            image = "pgsty/silo";
            # 9000 is the S3 API, 9001 the web console.
            ports = [ "127.0.0.1:9000:9000" "127.0.0.1:9001:9001" ];
            environment = {
              MINIO_ROOT_USER = "admin";
              MINIO_ROOT_PASSWORD = "admin123";
            };
            volumes = [ "silo-data:/data" ];
            cmd = [ "server" "/data" "--console-address" ":9001" ];
          };
        };
      };

      # Loader for prebuilt generic-Linux binaries, such as the Pythons that
      # `uv python install` downloads.
      programs.nix-ld.enable = true;
      # Extra libraries those binaries dlopen at runtime.
      programs.nix-ld.libraries = with pkgs; [
        file # libmagic, for python-magic

        # GLib and Pango, for WeasyPrint.
        fontconfig
        glib
        harfbuzz
        pango
      ];

      environment.systemPackages = [
        inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
}
