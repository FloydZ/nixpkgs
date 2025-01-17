Original code from [drupol](https://github.com/drupol/my-own-nixpkgs/tree/main/templates/my-own-nixpkgs)


### Integrating Your Repository as an Overlay

To use this repository as an overlay in another project, follow these steps:

1. **Add the Repository as an Input**:

   Add the following to your `nix` file to include this repository as an input:

   ```nix
   inputs = {
       custom-nixpkgs.url = "github:FloydZ/nixpkgs";
   };
   ```

2. **Include the Overlay in `pkgs`**:

   When constructing `pkgs`, include the overlay as follows:

   ```nix
   pkgs = import inputs.nixpkgs {
     overlays = [
       inputs.custom-nixpkgs.overlays.default
     ];
   };
   ```

3. **Use Your Packages**:

   Access the packages in your project like this:

   ```nix
   buildInputs = [ 
     pkgs.example1 
   ];
   ```
