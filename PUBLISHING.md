# Publishing sysup

The AUR package builds from GitHub's tarball for the `vX.Y.Z` tag. The sha256 can only be filled in **after** that tag is on GitHub, so do these steps in order.

## One-time setup

**AUR account and SSH key.** Register at <https://aur.archlinux.org/register>, then:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/aur -C "aur"
cat ~/.ssh/aur.pub      # paste this into AUR → My Account → SSH Public Key
printf 'Host aur.archlinux.org\n  IdentityFile ~/.ssh/aur\n  User aur\n' >> ~/.ssh/config
```

## First release (1.0.0)

**1. Push the code to GitHub.** Done: it lives at <https://github.com/arch-linux-system-updater/sysup>. Later changes go out with:

```bash
git push
```

**2. Tag the release.** This is what creates the tarball the AUR downloads:

```bash
git tag -a v1.0.0 -m "sysup 1.0.0"
git push origin v1.0.0
gh release create v1.0.0 --title "sysup 1.0.0" --generate-notes
```

**3. Fill in the real sha256:**

```bash
make aur                 # downloads the v1.0.0 tarball, writes sha256sums, regenerates .SRCINFO
git commit -am "aur: checksum for 1.0.0" && git push
```

**4. Test-build the package once:**

```bash
cd aur && makepkg -fc && namcap PKGBUILD *.pkg.tar.zst; rm -f *.pkg.tar.zst; cd ..
```

**5. Upload to the AUR.** Cloning a package name that doesn't exist yet gives you an empty repo, and pushing to it creates the package:

```bash
git clone ssh://aur@aur.archlinux.org/sysup.git ~/aur-sysup
cp aur/PKGBUILD aur/.SRCINFO ~/aur-sysup/
cd ~/aur-sysup
git add PKGBUILD .SRCINFO
git commit -m "Initial upload: sysup 1.0.0"
git push
```

It's live at <https://aur.archlinux.org/packages/sysup>, and anyone can install it with `paru -S sysup`.

## Every new version

1. Bump `SYSUP_VERSION` in `sysup` and the version in the header of `sysup.1`.
2. `git commit -am "sysup X.Y.Z" && git tag -a vX.Y.Z -m "sysup X.Y.Z" && git push --follow-tags`
3. `make aur` sets `pkgver` and the new sha256. Also reset `pkgrel=1` if it was bumped.
4. `git commit -am "aur: X.Y.Z" && git push`
5. Copy `aur/PKGBUILD` and `aur/.SRCINFO` into `~/aur-sysup`, commit, and `git push`.

If only the packaging changed and the version didn't, bump `pkgrel` instead, then run `makepkg --printsrcinfo > .SRCINFO` in `aur/` and do step 5.
