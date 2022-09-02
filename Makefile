# define standard colors
ifneq (,$(findstring xterm,${TERM}))
	BLACK        := $(shell tput -Txterm setaf 0)
	RED          := $(shell tput -Txterm setaf 1)
	GREEN        := $(shell tput -Txterm setaf 2)
	YELLOW       := $(shell tput -Txterm setaf 3)
	LIGHTPURPLE  := $(shell tput -Txterm setaf 4)
	PURPLE       := $(shell tput -Txterm setaf 5)
	BLUE         := $(shell tput -Txterm setaf 6)
	WHITE        := $(shell tput -Txterm setaf 7)
	RESET := $(shell tput -Txterm sgr0)
else
	BLACK        := ""
	RED          := ""
	GREEN        := ""
	YELLOW       := ""
	LIGHTPURPLE  := ""
	PURPLE       := ""
	BLUE         := ""
	WHITE        := ""
	RESET        := ""
endif

# 👆https://gist.github.com/rsperl/d2dfe88a520968fbc1f49db0a29345b9

.PHONY: build dev composer statamic npm up install

build: up
	@echo "Preparing to build..."
	@ddev exec npm run build
dev: up
	@ddev exec npm run dev
composer: up
	@ddev composer \
		$(filter-out $@,$(MAKECMDGOALS))
statamic: up
	@ddev exec php statamic \
		$(filter-out $@,$(MAKECMDGOALS))
npm: up
	@ddev exec npm \
		$(filter-out $@,$(MAKECMDGOALS))
install: up build
	@echo ""
	@echo "Downloading configuration..."

    # 👇 DL configure-statamic-for-ddev, a custom command (shell script) within
    # the web container which makes things right for ddev.
    # View the script in .ddev/commands/web/configure-stat-for-ddev.sh
    # Custom commands in DDEV are extremely powerful and easy to implement.
    # https://ddev.readthedocs.io/en/stable/users/extend/custom-commands/

	curl https://raw.githubusercontent.com/kerns/statamic-on-ddev/main/configure-statamic-for-ddev.sh -s -o .ddev/commands/web/configure-statamic-for-ddev.sh

	@echo "*** DONE ***"
	@ddev restart
	@ddev configure-statamic-for-ddev
	@ddev describe
	@ddev launch
up:
	@echo "${PURPLE}Preflight check...${RESET}"

# 👇 We'll grep for some strings ("web" and "OK") to understand if DDEV is already running
	@if [ ! "$$(ddev describe | grep -e web -e OK )" ]; then \
		echo "Your DDEV project is ${GREEN}starting...${RESET}"; \
		ddev config --project-type=laravel --docroot=public --php-version=8.1; \
		ddev auth ssh; \
		ddev start; \
		ddev get torenware/ddev-viteserve; \
		ddev composer install; \
		ddev exec npm install --loglevel=error --no-fund; \
		else \
		echo "${YELLOW}Your DDEV project is already running.${RESET}"; \
    fi
%:
	@:
# ref: https://stackoverflow.com/questions/6273608/how-to-pass-argument-to-makefile-from-command-line
