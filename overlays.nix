{ }:

[
  (final: prev: {
    vimPlugins = prev.vimPlugins.extend (f: p: {
      neotest = p.neotest.overrideAttrs {
        src = prev.fetchzip {
          url =
            "https://github.com/archie-judd/neotest/archive/c8dd7597bb4182c0547d188e1dd5f684a4f01852.zip";
          sha256 = "sha256-E/Heh+mAxvN5RaWqv1UJuHSA90c0evMKFkDD1BrpV7g=";
        };
      };
    });
  })
]
