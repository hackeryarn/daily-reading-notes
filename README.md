# Daily Reading Note

This repository has the source code and contents for the [Daily Reading
Notes](https://dailyreadingnotes.com) blog.

## Project Structure

All development should be done on the `develop` branch. The `master` branch
exists for hosting purposes only.

## Running the Project

This project uses [Hakyll](https://jaspervdj.be/hakyll/) for generation. `Hakyll`
requires `Haskell` and [Stack](https://docs.haskellstack.org/en/stable/README/).
Before running the project, you will need to install `Stack` by following their
[installation
instructions](https://docs.haskellstack.org/en/stable/README/#how-to-install).
`Stack` will take care of installing `Haskell` when you run the build command.

Once `Stack` is installed, **Make sure you are on the `develop` branch**. Then
run the following commands.

``` shell
# Build the base project and install all dependencies
$ stack build
# Run and watch the project locally
$ stack exec site watch
```

## Deploying the Project

Make sure site running locally by following the above commands. Then,
execute the provide make command.

``` shell
$ make deploy
```

