# omarchy-customization

## Repo structure:
```bash
omarchy-customization/
│
├── README.md
│
├── install.sh
│
├── inventory/
│   ├── collect.sh
│   ├── packages/
│   ├── applications/
│   └── configuration/
│
├── scripts/
│   ├── packages.sh
│   ├── applications.sh
│   ├── system.sh
│   ├── shell.sh
│   ├── development.sh
│   └── cleanup.sh
│
├── packages/
│   ├── packages.txt
│   ├── aur.txt
│   └── remove.txt
│
├── config/
│   ├── hypr/
│   ├── omarchy/
│   ├── foot/
│   ├── bash/
│   └── git/
│
├── hooks/
│   ├── post-boot
│   └── post-update
│
└── backup/
```

## Run collection script:
```bash
chmod +x inventory/collect.sh

./inventory/collect.sh
```
