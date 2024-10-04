This an example project demonstrating how to dockerize a basic Python
application that uses [asdf](https://asdf-vm.com/) and
[Poetry](https://github.com/python-poetry/poetry/) for dependency management.

# Caveats
- The generated Docker image contains a few dependencies that are not needed at
  application runtime. Ideally, one would use a multi-stage Docker build in
  order to not include those in the final Docker image and make the image
  smaller.
- apt dependencies are not fully pinned. Use e.g.
  [repro-sources-list.sh](https://github.com/reproducible-containers/repro-sources-list.sh)
  to achieve that.
