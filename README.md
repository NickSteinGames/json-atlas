# JSONAtlasTexture
## About
This is a small class based on AtlasTexture built into the Godot Engine.
It allows you to use '.json` files that are created when exporting sprite sheets (to Adobe Animate or Aseprite, for example).

## How to use?
First, download the plugin (from AssetLib, or through cloning this repository).
You don't need to enable anything, the "plugin" is 1 script defining a new class: `JSONAtlasTexture`.
Just open any property of the `Texture2D` type and select `JSONAtlasTexture` in the list of creating a new resource (it should be located directly under the original `AtlasTexture`)
After that, expand the `Data` group and drag `.png` (or any other image type supported by the engine) to `source_image` property and the Atlas itself will take the `.json` file.
> [!IMPORTANT]
> `.json` file must have EXACTLY the SAME name as the image from which the original image will be taken.
> for example:
> ✅✅✅
> ```
> 📁Sprites
>   ├─ 🎨 my_sprite.png
>   └─ 📃 my_sprite.json
> ```
> ❌❌❌
> ```
> 📁Sprites
>   ├─ 🎨 sprite_image.png
>   └─ 📃 sprite_json_data.json
> ```

> [!CAUTION]
> The script only supports atlases exported so that the `frames` element is a dictionary (`{}`), arrays are not supported yet.
