# spartan_check
_This service checks whether dcos-spartan is online and allow other systemd components to depend on it instead of the failing  but restartable `ping -c1 ready.spartan`_

### Instructions to Install

#### Download Spartan Check

1. Download the `oneshot-service-check` to your machine and move it within the bootstrap directory. 

```bash
curl -LO https://github.com/bernadinm/toolbox/raw/master/spartan_check/bin/oneshot-service-check
sudo mv oneshot-service-check /var/lib/dcos/bootstrap/.
sudo chmod +x /var/lib/dcos/bootstrap/oneshot-service-check
```

#### Create Spartan Check Service

2. Create the oneshot systemd unit service. 

```bash
cat << 'EOF' | sudo tee /etc/systemd/system/ready-spartan-checker.service
[Unit]
Description=ready.spartan startup assert check
Documentation=https://www.freedesktop.org/software/systemd/man/systemd.unit.html
Wants=dcos-spartan.service
After=dcos-spartan.service

[Service]
Type=oneshot
SyslogIdentifier=ready-spartan
ExecStart=/var/lib/dcos/bootstrap/oneshot-service-check
TimeoutStartSec=infinity
EOF
```

#### Depend External Systemd on Spartan Check Service

3. Have your any systemd service depend on the spartan checker. 

_Example: In this case below, there is a mount systemd unit waiting for spartan._


```bash
cat << 'EOF' | sudo tee /etc/systemd/system/tmp-test.mount
[Unit]
Description=Temporary Directory
Documentation=https://www.freedesktop.org/software/systemd/man/systemd.unit.html
Conflicts=umount.target
Wants=ready-spartan-checker.service
After=ready-spartan-checker.service

[Mount]
What=tmpfs
Where=/tmp/test
Type=tmpfs
Options=mode=1777,strictatime

[Install]
WantedBy=multi-user.target
EOF
```

#### Enable Your Systemd Service

4. Update systemd daemon and enable the example mount unit.

```bash
sudo systemctl daemon-reload
sudo systemctl enable tmp-test.mount 
```

#### Test Results of Dependancy

5. Test the result by rebooting your machine

```bash
sudo systemctl reboot
```
