# CLAUDE.md LSP Section for PHP

## Code Intelligence (LSP)

### Navigation & Understanding
- Use LSP `goToDefinition` before modifying unfamiliar classes, methods, or traits
- Use LSP `findReferences` before refactoring—critical for trait usage and interfaces
- Use LSP `documentSymbol` to understand class structure and namespaces
- Prefer LSP navigation over grep—it resolves through use statements and autoloading

### Verification Workflow
- Check LSP diagnostics after each edit to catch parse and type errors
- Run `php -l` for syntax checking or use PHPStan/Psalm for static analysis
- Verify use statements are correct and autoloading works

### Pre-Edit Checklist
- [ ] Navigate to definition to understand implementation
- [ ] Find all references to assess change impact
- [ ] Review type hints and docblocks via hover
- [ ] Check if modifying public API used by other packages

### Error Handling
- If LSP reports errors, fix them before proceeding
- Pay attention to type mismatch warnings from PHPStan/Psalm
- Use LSP diagnostics to understand namespace issues

## PHP Tooling

### Composer
- Install: `composer install`
- Update: `composer update`
- Autoload dump: `composer dump-autoload`
- Require: `composer require package/name`

### Quality Gates
- Syntax check: `php -l src/*.php` or `find src -name '*.php' -exec php -l {} \;`
- PHPStan: `./vendor/bin/phpstan analyse`
- Psalm: `./vendor/bin/psalm`
- PHP CS Fixer: `./vendor/bin/php-cs-fixer fix`
- PHP CS Fixer check: `./vendor/bin/php-cs-fixer fix --dry-run --diff`
- PHPUnit: `./vendor/bin/phpunit`

### Before Committing
```bash
./vendor/bin/php-cs-fixer fix --dry-run --diff && ./vendor/bin/phpstan analyse && ./vendor/bin/phpunit
```

### Useful Commands
- `composer show` — List installed packages
- `composer outdated` — Check for updates
- `composer validate` — Validate composer.json

## Language Server Details

- **Server**: phpactor
- **Install**: `composer global require phpactor/phpactor`
- **PATH**: Ensure `~/.composer/vendor/bin` is in PATH
- **Features**: PHP 7.4+ support, class/method navigation, refactoring
