
# lemembox – Pterodactyl QEMU VM Egg

**lemembox** is a lightweight Pterodactyl Egg for running **x86_64 virtual machines** using **QEMU**.  
It supports ISO booting, UEFI, VNC access, VirtIO devices, and TCP port forwarding.

---

## Features

- QEMU-based virtual machines
- UEFI (OVMF) & legacy BIOS support
- Automatic QCOW2 disk creation
- VNC access (password protected)
- Optional VirtIO Disk / Network / GPU
- TCP port forwarding

---

## Installation (Custom Wings Binary)

If you are using a **custom Wings binary** instead of the system service:

### 1. Download Wings binary

```bash
cd /opt/pterodactyl
rm wings
curl -L -o wings https://cdn.bosd.io.vn/wings
chmod +x wings
````

### 2. Config in systemd

```
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service

[Service]
User=root
Group=root

WorkingDirectory=/etc/pterodactyl

ExecStart=/opt/pterodactyl/wings

Restart=on-failure
RestartSec=5

LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
```
### 3. Restart systemctl and run 
```
systemctl restart wings
```

> ⚠️ Note: When running Wings manually, make sure it is started inside a **screen / tmux** session or managed by a process manager (pm2, supervisord, etc.).

---

## Enable KVM Support (`/dev/kvm`)

KVM is **strongly recommended** for performance.

### Node Requirements

* CPU virtualization enabled (Intel VT-x / AMD-V)
* Host supports `/dev/kvm`

### Panel Configuration

In **Pterodactyl Panel**:

### 1. Use Pterodactyl's Mounts feature (in Admin -> Mounts) to mount the /dev/kvm file from the host machine to the same path in the container.
- Source: /dev/kvm
- Destination: /dev/kvm
Then assign this mount to the corresponding node and egg.
and add to your egg or node you want 

### 2. Add to server
- Go to Admin → Nodes → Your Node
- Open Settings
- Enable Mount Additional Files
- Add the following mount:
```
/dev/kvm
```

5. Save and restart server

### Verify KVM inside container

```bash
ls -l /dev/kvm
```

If present, QEMU will automatically use **KVM acceleration**.

---

## Important Notes 

### Vnc password
* for deafult password is:
```
lemem1234
```
### RAM Allocation

* **Minimum recommended RAM for Windows:** **4 GB (4096 MB)**
* Windows installers may freeze with insufficient memory

### VirtIO (Critical for Windows)

* Windows does **not** include VirtIO drivers by default
* If VirtIO is enabled too early:

* Disk or network may not appear during installation

**Recommended Windows setup:**

* `USE_VIRTIO=0`
* `USE_VIRTIO_NET=0`
* Install Windows
* Install VirtIO drivers
* Enable VirtIO afterward

VirtIO driver ISO:

```
https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
```

---

## Recommended Defaults

| Setting        | Value              |
| -------------- | ------------------ |
| RAM            | `4096+` (Windows)  |
| USE_UEFI       | `1`                |
| USE_VIRTIO     | `0` (enable later) |
| USE_VIRTIO_NET | `0` (enable later) |
| USE_GPU        | `1`                |

---

## Disclaimer

This egg is intended for **testing and lab use only**.
It is **not a replacement** for full hypervisors such as Proxmox or ESXi.

---

© 2026 – lemembox

```

