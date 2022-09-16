# Getting KV name by env

## Requirements
- jq
```
sudo apt-get install jq
```
- az-cli
```

```

## Getting by product name and env
``` az keyvault list  --resource-group <core_rg_name> --subscription <subscription_name> | jq --arg product "<product_name>" --arg env "<env>" '.[] | select(.tags.ProductName==$product and .tags.Environment == $env) | .name ' ```

Change <env> by desired environment (dev, stv, prg).


