# JSONAtlasTexture
## About
This is a small class based on AtlasTexture built into the Godot Engine.
It allows you to use '.json` files that are created when exporting sprite sheets (to Adobe Animate or Aseprite, for example).

## Features
  - [x] Selecting the displayed `frame` through the `enumeration list`
  - [x] Automatic loading of a `JSON file` when an `image file` is selected.
### Planned
  - [ ] Supporting a `frames` as `Array`.
### Planned (but not guaranteed)
  - [ ] The function of automatic atlases creation via `Impor Tab`
  - [ ] A completely independent class `JSONAtlas...` (without inheriting `AtlasTexture`)

## How to use?
First, download the plugin (from [AssetLib](https://godotengine.org/asset-library/asset/4058), or through cloning this repository).
You don't need to enable anything, the "plugin" is 1 script defining a new class: `JSONAtlasTexture`.
Just open any property of the `Texture2D` type and select `JSONAtlasTexture` in the list of creating a new resource (it should be located directly under the original `AtlasTexture`)
After that, expand the `Data` group and drag `.png` (or any other image type supported by the engine) to `source_image` property and the Atlas itself will take the `.json` file.
> [!IMPORTANT]
> `.json` file must have EXACTLY the SAME name as the image from which the original image will be taken.
> for example:\
> ✅✅✅
> ```go
> 📁Sprites
>   ├─ 🎨 my_sprite.png
>   └─ 📃 my_sprite.json
> ```
> ❌❌❌
> ```go
> 📁Sprites
>   ├─ 🎨 sprite_image.png
>   └─ 📃 sprite_json_data.json
> ```

> [!CAUTION]
> The script only supports atlases exported so that the `frames` element is a dictionary (`{}`), arrays are not supported yet.


