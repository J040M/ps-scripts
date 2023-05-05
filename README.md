# Cloudflare certificates + Warp installation script

## Powershell configuration

### Powershell execution policy

For signed scripts

```# Set-ExecutionPolicy RemoteSigned```

For unsigned scripts !!!This will allow unresctructed Powershell script execution, leaving the door open to threats!!!

```# Set-ExecutionPolicy unrestricted```

Unset Powershell script execution

```# Set-ExecutionPolicy undefined```


### Privileges

The installation requires higher privileges. Run Powershell with Administrator rights.