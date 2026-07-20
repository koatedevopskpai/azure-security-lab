# Module 02: Remote Access VPN — Architecture (Azure)

## Scenario

Remote employees need secure point-to-site VPN access to internal Azure resources. Azure VPN Gateway provides managed VPN termination with multiple authentication options.

## Azure Solution: VPN Gateway (P2S)

Azure VPN Gateway supports site-to-site (S2S), point-to-site (P2S), and VNet-to-VNet connections. This lab implements P2S with certificate authentication.

### Architecture

```
┌──────────────────┐     IPsec/IKEv2   ┌──────────────────┐
│  Remote User     │◄══════════════►  │  Azure Cloud     │
│  (laptop)        │                   │                   │
│  Azure VPN       │                   │  ┌────────────┐  │
│  Client          │                   │  │VPN Gateway │  │
└──────────────────┘                   │  │(GwSubnet)  │  │
                                       │  └─────┬──────┘  │
                                       │        │         │
                                       │  ┌─────┴──────┐  │
                                       │  │Workload    │  │
                                       │  │(workload   │  │
                                       │  │ subnet)    │  │
                                       │  └────────────┘  │
                                       └──────────────────┘
```

### Key Components

| Component | Azure Resource | Purpose |
|-----------|---------------|---------|
| VPN Gateway | `azurerm_virtual_network_gateway` | Managed VPN termination, P2S support |
| GatewaySubnet | `azurerm_subnet` | Dedicated subnet for gateway (must be named GatewaySubnet) |
| Root Certificate | `tls_self_signed_cert` | Client authentication |
| Public IP | `azurerm_public_ip` | Gateway endpoint address |

### SDCI 300-745 Connection

This maps to the **Internet Edge + VPNs** scenario: VPNs at the edge provide secure tunnels for remote employees to access internal applications, consistent with the exam objective of Internet Edge security.
