Release out now to handle autofix

<img width="468" alt="image" src="https://github.com/samfisherirl/SetVSCodiumExtensionGallery/assets/98753696/6dedb3e2-3e9e-42ef-b315-f382d6f48a96">



I just spent about half an hour reading through Github issues and source code of VSCode & VSCodium to figure out how to get Pylance working. In short:

```%LOCALAPPDATA%\Programs\VSCodium\resources\app```

-   The workaround described [here](https://github.com/VSCodium/vscodium/issues/892#issuecomment-986663776) suggests editing a `product.json` file, but `find $HOME/.var/app/com.vscodium.codium -name 'product.json'` returns nothing
-   Found [product.json should be editable #22](https://github.com/flathub/com.vscodium.codium/issues/22) which links to [customize the extensions gallery VSCodium/vscodium#674](https://github.com/VSCodium/vscodium/pull/674)
-   The linked PR contains a [patch](https://github.com/VSCodium/vscodium/blob/3277bd4fa19f262fa1d1a1fb916b4d6d9e0bd134/patches/custom-gallery.patch#L35) which looks for a user-provided `product.json` *to merge into* the compiled-in values - by default, no `product.json` is included in shipped builds
-   Dropping the following file into `$HOME/.var/app/com.vscodium.codium/config/VSCodium/product.json` lets me run Pylance:

```
{
  "nameShort": "Visual Studio Code",
  "nameLong": "Visual Studio Code",
  "extensionsGallery": {
    "serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery",
    "cacheUrl": "https://vscode.blob.core.windows.net/gallery/index",
    "itemUrl": "https://marketplace.visualstudio.com/items"
  }
}

```

As this is a rather specific workaround to a specific problem, perhaps just including a note somewhere is enough to spare others from having to go through the same journey.
