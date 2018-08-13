# Changelog
All notable changes to this project will be documented in this file.

## Unreleased
### Added
- `Rack::BlastWave::RequestId` - rack middleware that provides an unique id attribute
  to the each rack request object and rack `#env` scope;
- `Rack::BlastWave::WhiteList` - rack middleware that blocks or allows requests
  by filtering them via predefined list of filters: failed filters blocks current request,
  successful filters allows current request.
- `Rack::BlastWave::BlackList` - rack middleware that blocks or allows requests
  by filtering them via predefined list of filters: failed filters allows current request,
  successful filters blocks current request.
