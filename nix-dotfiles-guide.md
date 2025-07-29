# A Practical Guide to Managing Your Dotfiles with Nix

This guide explains how to use Nix with [Home Manager](https://github.com/nix-community/home-manager) and [Flakes](https://nixos.wiki/wiki/Flakes) to create a reproducible, declarative, and portable development environment. The goal is to have a single Git repository that contains all your configurations, which you can then deploy on any machine, including non-NixOS systems.

In simple terms, a nix dotfiles repo is a folder with a `flake.nix` file (the entry point of the configuration) that we'll use to rebuild the same environment on any machine. We'll use `home-manager` to manage the user's environments, and if needed we'll have host specific configurations under the `hosts` folder (if you use multiple devices, each likely have different hardware to account for).

This setup is made for a single user, I don't know how a multi-user setup would work (yet).

## Core Concepts

### Nix

Nix is a powerful package manager for Linux and other Unix-like systems. What makes it unique is its purely functional and declarative approach.

- **Declarative**: You describe the desired state of your system (e.g., "I want packages `git`, `neovim`, and `ripgrep` to be installed"), and Nix figures out how to achieve it.
- **Reproducible**: Nix builds packages in isolation from the rest of the system, in a special directory (`/nix/store`). This ensures that builds are reproducible and don't interfere with each other. If a package works on one machine, it will work on another.

### Home Manager

Home Manager is a tool that specializes in managing a user's environment. You can declaratively manage:

- Packages installed in your user profile.
- Dotfiles (like `.zshrc`, `.gitconfig`).
- User services (`systemd` services).

It's the key to replacing traditional dotfile management scripts.

### Nix Flakes

Flakes are the modern, standard way to package Nix expressions and manage dependencies. They improve reproducibility by pinning the exact versions of all inputs (like the `nixpkgs` package set) in a `flake.lock` file.

A `flake.nix` file in the root of your repository defines everything about your configuration:

- `inputs`: The dependencies of your configuration, like `nixpkgs` (the collection of all Nix packages) and `home-manager`.
- `outputs`: What your flake provides. For our use case, this will be your user environment configurations.

**A note on flakes**: Technically, you can forego using flakes and just use `home-manager` to manage your dotfiles. However, flakes offer portability and code organization benefits:

- Reproducibility: Flakes pin the exact versions of all inputs, ensuring identical environments everywhere (even non-NixOS systems).
- Code organization: Flakes allow you to organize your configuration into modules, making it easier to reuse and share.
- Portability: Flakes can be used on any system that supports Nix, not just NixOS.

## 1. Getting Started: Your First Configuration

Create a new Git repository for your configurations. This is your new "dotfiles" repo.

**Where should you clone it?**
The ideal location is inside your home directory, for example: `~/dotfiles`.

The primary reason is **permissions**. By cloning it in your home directory, you can edit your configuration files without needing `sudo`, which is essential for a smooth and fast development workflow.

The structure should look like this (only an empty `flake.nix` for now):

```bash
dotfiles/
├── flake.nix
├── home/
│   ├── common.nix
│   └── luchillo17@wsl.nix
├── hosts
│   └── my-nixos.nix
├── profiles/
│   └── development.nix
└── README.md
```

There are 3 starting points that all merge in the same result, which is to have a `~/dotfiles` folder that rules over the installed libraries, programs and dotfiles in your OS:

1. NixOS: Start from a fresh or existing install of NixOS (simplest).
2. Unix based OS: Any existing Unix based OS, like Ubuntu or MacOS.
3. WSL2: For those like me that can't forego Windows because of games support.

### 1.1 NixOS start

This is the simplest one simply because when you install a fresh NixOS system, it comes pre-installed with Nix.

If you're not using a fresh install, update to the latest NixOS version before continuing.

#### Step 1: Enable Flakes

In your nix config `/etc/nixos/configuration.nix` find the `environment.systemPackages` section, enable `experimental-features` and add at least `git`, `vim` and `wget` to the list.

```nix
{ config, pkgs, ... }:

{
  # ......

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  environment.systemPackages = with pkgs; [
    # Flakes clones its dependencies through the git command,
    # so git must be installed first
    git
    vim
    wget
  ];
  # Set the default editor to vim
  environment.variables.EDITOR = "vim";

  # ......
}
```

Then rebuild the system with `sudo nixos-rebuild switch`, from this point the system will look for the `/etc/nixos/flake.nix` before falling back to `/etc/nixos/congfiguration.nix`.

Source: [NixOS with Flakes#Enable Nix Flakes](https://nixos-and-flakes.thiscute.world/nixos-with-flakes/nixos-with-flakes-enabled#enable-nix-flakes)

#### Step 2: The system flake

CD into `/etc/nixos/` and run `sudo nix flake init`, it will use the default template to create the system flake, from which we'll link our dotfiles's flake (we'll take a look at the templates later), then replace the `outputs` section (remember to replace `my-nixos` with your hostname).

```nix
{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs }: {

    # Please replace my-nixos with your hostname & system with your system architecture
    nixosConfigurations.my-nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        ./configuration.nix
      ];
    };

  };
}
```

Now run `sudo nixos-rebuild switch` to apply the changes (nothing will change, but now the system will look for the `/etc/nixos/flake.nix` before falling back to `/etc/nixos/congfiguration.nix`), it might take a while to build if you've updated the channel.

Source: [NixOS with Flakes#Switch to flake.nix](https://nixos-and-flakes.thiscute.world/nixos-with-flakes/nixos-with-flakes-enabled#switch-to-flake-nix)

#### Step 3: Move the flake.nix and dependencies to the dotfiles repo

At this point you should have a minimal but working flake, now we're moving the config into the dotfiles repo, from inside the dotfiles folder run:

```bash
cp /etc/nixos/* ./
```

Then from this point on you have to use the flakes flag to tell Nix where to load the flake from (we copy and leave the originals there just to be safe):

```bash
sudo nixos-rebuild switch --flake .

# If your hostname does not match any in the flake you might need to specify which configuration to apply
# Please replace my-nixos with your hostname
sudo nixos-rebuild switch --flake .#my-nixos
```

Now you should have a very basic and portable flakes based dotfiles, it is worth noting its currently specific to this device, that is because we copied the `configuration.nix` and `hardware-configuration.nix` which are setup for this host, the flake is general but now if you want to support multiple devices we need to delve into the `hosts` folder later in this guide.

#### Step 4: Home Manager setup

Although it is possible to install and manage everything in `configurations.nix`, it is less than ideal, as it is intended to handle OS level config, like bluetooth, wifi, peripherals and such, it is recommended to use Home Manager to handle user specific configs, like installing CLI utilities (think of `wget` or `htop`), programs (like Chrome or Ghostty) and dotfiles level configs (usually what you would put under `.bashrc` or `.zshrc` outside of Nix).

There are multiple ways to handle Home Manager but we are going to use a semi-standalone way for 2 reasons:

- Is more compatible with Non NixOX systems.
- More important we want to decouple the NixOS switch run from Home Manager switch, the OS level one takes ages.

First lets add the `home-manager` package to the `configurations.nix`:

```nix
{
  # ...
  nix.settings.experimental-features = [ "nix-command" "flakes"];
  environment.systemPackages = with pkgs; [
    home-manager # This line
    git
    vim
    wget
  ];
  # ...
}
```

It is hard to explain all the changes you need to make to enable a separate Home Manager config in the flake, so here is a peek at the `flake.nix` after enabling it, with a bit more advanced techniques:

```nix
{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }@inputs:
  let
    user = "my-user";
    host = "nixos-alienware";
    system = "x86_64-linux";
    stateVersion = "25.05";
  in {

    nixosConfigurations.${host} = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit system stateVersion;
      };
      modules = [
        ./hosts/${host}/configuration.nix
      ];
    };

    homeConfigurations.${user} = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = {
        inherit inputs stateVersion user;
      };
      modules = [ ./home ];
    };
  };
}
```

A few things to notice:

- We are setting the nixos version to `25.05` everywhere, at the time of writing it is the latest stable OS version.
- We are using variables to pass around repeated values, like the `home-manager`, `user`, `host`, `system` and `stateVersion`.
- We are interpolating those variables in a few places with the `.${}` syntax.
- The `specialArgs` and `extraSpecialArgs` are there to pass the inputs and variables down to the modules and submodules.
- Inherit is syntax suggar for `{ inputs = inputs; }`.
- Modules is how we tell the flake configs to load those files in that configuration.
- Even though we are installing Home Manager in the host config, we are configuring it in a different config `homeConfigurations`, that is so we can run the home manager build by itself instead of rebuiling the whole OS.

Then we have the `home.nix`, you will notice we are using again the `user` and `stateVersion` variables and setting/interpolating them in the proper places:

```nix
{ config, pkgs, stateVersion, user, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = user;
  home.homeDirectory = "/home/${user}";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = stateVersion;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
```

Now you can install stuff using the properties Home Manager offers, and have that be specific to your user (I think installed programs share the same nix storage but are only available to each user that is configured to have them installed, and the dotfiles of CLI utils and programs that support that would be user specific).

Here is a minimal example with Zsh and OhMyZsh in the Home Manager way:

```nix
{
  # ...
  programs.zsh = {
    enable = true;
    enableCompletions = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      la = "ls -lah";
    };
    history.size = 10000;

    oh-my-zsh = { # "ohMyZsh" without Home Manager
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "thefuck" ];
    };
  };
}
```

Now you can run `home-manager switch --flake .#my-user` to install the home manager config in `home.nix`.

## 2. Adding hosts

If you already have a flake based `dotfiles` repo, you need to know how to add hosts to it, at some point you'll want to have multiple machines where you share the same dotfiles.

---

### Step 1: Install Nix and Enable Flakes

First, install Nix on your system using the [Determinate Systems Nix Installer](https://github.com/DeterminateSystems/nix-installer).

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

---

### Step 1: Install Nix and Enable Flakes

First, install Nix on your system using the [Determinate Systems Nix Installer](https://github.com/DeterminateSystems/nix-installer).

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

After installation, enable the experimental Flakes feature by adding the following line to `~/.config/nix/nix.conf` (create the file if it doesn't exist):

```ini
experimental-features = nix-command flakes
```

### Step 2: Set Up Your Repository Structure

Create a new Git repository for your configurations. This is your new "dotfiles" repo.

### Step 3: Create the `flake.nix` Entry Point

The `flake.nix` file is the heart of your configuration. It defines your dependencies (`nixpkgs`, `home-manager`) and your outputs (the configurations for each machine).

```nix
# flake.nix
{
  description = "My Nix-based development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux"; # Adjust for your system if needed
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations = {
        # Define a configuration for a specific user@host
        "luchillo17@wsl" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home/luchillo17@wsl.nix ];
        };
      };
    };
}
```

### Step 4: Create Shared and Host-Specific Configurations

- **`home/common.nix`**: Contains settings you want on _every_ machine.
- **`home/luchillo17@wsl.nix`**: Contains settings for one specific machine, and imports any "profiles" it needs.

```nix
# home/common.nix
{ pkgs, ... }: {
  home.username = "luchillo17";
  home.homeDirectory = "/home/luchillo17";
  home.stateVersion = "25.05"; // Use the current NixOS version

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # Universal packages and settings
  home.packages = with pkgs; [ htop ];
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "your.email@example.com";
  };
}
```

```nix
# home/luchillo17@wsl.nix
{ ... }: {
  imports = [
    ./common.nix # Import shared settings
    ../profiles/development.nix # Import a role-specific profile
  ];
  # Add any other machine-specific settings here
}
```

### Step 5: Define Reusable Profiles (optional)

Profiles allow you to group configurations by role (e.g., development, video editing).

```nix
# profiles/development.nix
{ pkgs, ... }: {
  home.packages = with pkgs; [
    neovim
    ripgrep
    fzf
    zsh
    starship
  ];
}
```

### Step 6: Apply Your Configuration

Navigate to the root directory of your cloned dotfiles repository in your terminal. This step is crucial because the following command uses `.` to tell Home Manager to look for your `flake.nix` file in the current directory.

Run the `switch` command to build your environment:

```bash
# The format is .#<user>@<host> from your flake.nix
home-manager switch --flake .#luchillo17@wsl
```

**How it works:** The `--flake .#...` argument tells Home Manager to find the `flake.nix` file in the current working directory (`.`), and then apply the configuration specified after the `#`.

1. **Add your dotfiles repo as an input** to your NixOS flake. For local development, point to the path of your local clone. This avoids needing to commit every change.

   ```nix
   # /etc/nixos/flake.nix
   inputs = {
     nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
     # For development, use a local path:
     dotfiles.url = "path:/home/luchillo17/path/to/your/nix-dotfiles";
     # When deploying, you can switch to a github url:
     # dotfiles.url = "github:your-username/nix-dotfiles";
   };
   ```

   **Note:** When using a local path, Nix will only see files staged with `git add`. You don't need to commit.

2. **Import the home-manager module** and your user's configuration.

   ```nix
   # /etc/nixos/flake.nix outputs section
   modules = [
     ./configuration.nix # Your main NixOS config
     # Import home-manager itself
     inputs.dotfiles.inputs.home-manager.nixosModules.home-manager
     {
       home-manager.useGlobalPkgs = true;
       home-manager.useUserPackages = true;
       # Tell home-manager to build the config for your user
       home-manager.users.luchillo17 = import ./path/to/your/home/luchillo17@<hostname>.nix;
     }
   ];
   ```

3. **Rebuild your NixOS system**:

   ```bash
   sudo nixos-rebuild switch --flake /etc/nixos#<your-nixos-hostname>
   ```

---

## 3. Frequently Asked Questions (FAQ)

**Q: Why use Flakes if they are experimental?**
**A:** Flakes provide three huge benefits that the community has widely adopted:

1. **True Reproducibility**: Your `flake.lock` file pins the exact version of every dependency, guaranteeing identical environments everywhere.
2. **Standardized Structure**: The `inputs` and `outputs` format makes every Nix project predictable and easy to use.
3. **Composability**: Flakes are designed to be used as building blocks inside other flakes, which is exactly how we use `home-manager` here.

**Q: How do I manage secrets (like tokens or private keys)?**
**A:** Do not store secrets directly in your Nix files, as they will end up in the world-readable `/nix/store`. The best practice is to use a dedicated secrets management tool. [agenix](https://github.com/ryantm/agenix) is a popular choice that works well with Nix. It allows you to store secrets encrypted in your Git repository, and they are only decrypted on the target machine.

**Q: How do I manage different system architectures (e.g., x86 and ARM)?**
**A:** Your `flake.nix` can be easily extended to support multiple architectures. You can define a configuration for each system and pass the appropriate `pkgs` set to it.

```nix
# flake.nix
outputs = { ... }: {
  let
    systems = ["x86_64-linux", "aarch64-darwin"]; # etc.
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in
  {
    homeConfigurations = forAllSystems (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        "your-user@${system}-host" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          # ...
        };
      });
  };
};
```

**Q: What's the difference between `home-manager switch` and `nixos-rebuild switch`?**
**A:**

- `home-manager switch`: Manages **only** the user environment (dotfiles, user packages, user services). You use this on non-NixOS systems (like Ubuntu, macOS) or when you want to update just your user profile on NixOS.
- `nixos-rebuild switch`: Manages the **entire** operating system (kernel, system-wide services, system packages, drivers, etc.). If you integrate home-manager into your NixOS configuration, this command will also manage your user environment as part of the system-wide update.
