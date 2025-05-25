<h1>
  <img src="https://dhfrjz15mb441.cloudfront.net/kanndeutsch/logo.png" alt="Logo" width="28" style="position: relative; top: 5px;">
  KannDeutsch
</h1>

A simple German-English English-German dictionary app for iOS, using data from dict.cc.

> [!NOTE]
> I'm currently working on the search functionality, right now it's really basic and won't usually find what you're looking for.

## Development

Make sure you have git LFS installed to clone this repository, as it contains large files.

## Building

To build the app on a non-macOS system, you need to have `xtool` installed. Follow [their guide](https://xtool.sh/documentation/xtool/installation-linux/) to install it.

After connecting your iOS device, run the following command in the root directory of the project:

```bash
xtool dev
```

## Acknowledgements

This project uses data from [dict.cc](https://www.dict.cc/).