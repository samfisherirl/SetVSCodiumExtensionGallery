```batch
set VSCODE_GALLERY_SERVICE_URL='https://marketplace.visualstudio.com/_apis/public/gallery'
set VSCODE_GALLERY_ITEM_URL='https://marketplace.visualstudio.com/items'
set VSCODE_GALLERY_CACHE_URL='https://vscode.blob.core.windows.net/gallery/index'
set VSCODE_GALLERY_CONTROL_URL=''
```

How to use a different extension gallery
You can switch from the pre-set Open VSX Registry by configuring the endpoints using the following solutions. These examples use the URLs for Microsoft's VS Code Marketplace, see below for more information on that.

With the following environment variables:


VSCODE_GALLERY_SERVICE_URL='https://marketplace.visualstudio.com/_apis/public/gallery'
VSCODE_GALLERY_ITEM_URL='https://marketplace.visualstudio.com/items'
VSCODE_GALLERY_CACHE_URL='https://vscode.blob.core.windows.net/gallery/index'
VSCODE_GALLERY_CONTROL_URL=''
Or by creating a custom product.json at the following location (replace VSCodium by VSCodium - Insiders if you use that):
```
Windows: %APPDATA%\VSCodium or %USERPROFILE%\AppData\Roaming\VSCodium
macOS: ~/Library/Application Support/VSCodium
Linux: $XDG_CONFIG_HOME/VSCodium or ~/.config/VSCodium
with the content:
```
Note: set cacheUrl to empty string for every other extension gallery
