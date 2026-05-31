Switches a compiled neural network to one of its named quality configurations. Check `getNetworkInfo().qualityConfigurations` first, then pass one of those IDs to avoid runtime errors.

```javascript
const var info = nn.getNetworkInfo();

if (info.qualityConfigurations.contains("high"))
    nn.setQualityConfiguration("high");
```

This method resets the compiled model after switching and kills active voices before the swap. It is intended for explicit quality changes, not high-frequency automation.

The method fails if the network is `empty`, if it is `dynamic`, or if the requested quality ID is not registered. Unknown quality IDs report the available configurations.

> [!Warning:Compiled models only] Quality configurations only apply to compiled neural networks. Empty or dynamic networks report a script error.
