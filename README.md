# JSONAtlasTexture

<p align="center">
	<img src="icon.png" alt="AtlasTexture JSON Icon">
</p>

## About

Custom class for the Godot Engine based on `AtlasTexture`.
This class uses the `.json` files that are created when exporting sprite sheets to compile Symbols / Tags and their respective frames to create a sprite.

Currently supported sprite sheet formats:
- Aseprite
- Adobe Animate / Flash

## Features

- [x] Automatic loading of a `.json` file when the `texture` is loaded.
- [x] Aseprite's Tags and Adobe Animate / Flash's Symbols seperated in sections through the `symbol` property.
- [x] Texture scaling through a `scale` property within the `JSONAtlasTexture`.
  - [x] Customisable scale interpolation via `scale_behaviour` property.
- [x] Customisable `frame` looping behaviour via `frame_behaviour` property.

### Planned

- [ ] Aseprite custom formatting options.

### Tentative

- [ ] Automatic Atlas creation with presets via the `Import` tab.
- [ ] A completely independent class `JSONTexture` (without inheriting `AtlasTexture`).

## Instructions

1. Download the plugin (from [AssetLib](https://godotengine.org/asset-library/asset/4058), or through cloning this repository).
2. No enabling required, this "plugin" is really just a script that adds a new class to your project.
3. Create a new resource instance of `JSONAtlasTexture` on any `Texture2D`-based property.
4. Load your source image into the `texture` property of the resource.
5. Select the sprite and frame you want via the `symbol` and `frame` properties.

### Exporting

> [!IMPORTANT]
> When Exporting from __Aseprite__,
>The `Item Filename` format must be:
>```
> {tag}{tagframe0000}
>```

> [!IMPORTANT]
> The `.json` file must have __the same base name__ as your texture image.
>
> ✅ YES:
> ```go
> 📁Sprites
>   ├─ 🎨 sprite.png
>   └─ 📃 sprite.json
> ```
> ❌ NO:
> ```go
> 📁Sprites
>   ├─ 🎨 sprite_image.png
>   └─ 📃 sprite_json_data.json
> ```

## Issues

- JSON file is not updated automatically ([#2](https://github.com/NickSteinGames/json-atlas/issues/2#issue-3105885503))

## Major Contributors

- @NickStienGames
- @pikuler
