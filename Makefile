PREFIX     ?= /usr
SYSCONFDIR ?= /etc
DESTDIR    ?=
NAME       := sysup
VERSION    := $(shell sed -n 's/^SYSUP_VERSION="\(.*\)"/\1/p' sysup)

BINDIR  = $(DESTDIR)$(PREFIX)/bin
SHARE   = $(DESTDIR)$(PREFIX)/share

.PHONY: all install uninstall check aur

all:
	@echo "Nothing to build. Run 'make install' (or 'make check')."

install:
	install -Dm755 sysup                  $(BINDIR)/sysup
	install -Dm644 sysup.conf             $(DESTDIR)$(SYSCONFDIR)/sysup.conf
	install -Dm644 sysup.1                $(SHARE)/man/man1/sysup.1
	install -Dm644 completions/sysup.bash $(SHARE)/bash-completion/completions/sysup
	install -Dm644 completions/_sysup     $(SHARE)/zsh/site-functions/_sysup
	install -Dm644 completions/sysup.fish $(SHARE)/fish/vendor_completions.d/sysup.fish
	install -Dm644 README.md              $(SHARE)/doc/$(NAME)/README.md
	install -Dm644 LICENSE                $(SHARE)/licenses/$(NAME)/LICENSE

uninstall:
	rm -f $(BINDIR)/sysup $(SHARE)/man/man1/sysup.1 \
	      $(SHARE)/bash-completion/completions/sysup \
	      $(SHARE)/zsh/site-functions/_sysup \
	      $(SHARE)/fish/vendor_completions.d/sysup.fish
	rm -rf $(SHARE)/doc/$(NAME) $(SHARE)/licenses/$(NAME)

check:
	bash -n sysup
	shellcheck -x sysup completions/sysup.bash

# Run after the v$(VERSION) tag is on GitHub: downloads GitHub's tarball,
# writes its real sha256 into aur/PKGBUILD and regenerates aur/.SRCINFO.
aur:
	sed -i 's/^pkgver=.*/pkgver=$(VERSION)/' aur/PKGBUILD
	cd aur && updpkgsums && makepkg --printsrcinfo > .SRCINFO
	rm -f aur/$(NAME)-*.tar.gz
	@grep '^sha256sums' aur/PKGBUILD
