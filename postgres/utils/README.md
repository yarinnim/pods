# PostgreSQL Backup Utilities

This repository contains utility functions for PostgreSQL backup operations.

## Setup

1. Copy `env-example` to `.env`:
```bash
cp env-example .env
```

2. Edit `.env` with your configuration:
```bash
nano .env
```

## Common Functions

### get_databases
Returns an array of databases to backup.

```bash
# Usage
databases=($(get_databases))

# Example
for db in "${databases[@]}"; do
    echo "Processing database: $db"
done
```

### check_destination_file
Checks if a file exists on the backup server.

```bash
# Usage
check_destination_file

# Required environment variables:
# - SSH_PRIVATE_KEY: Path to SSH private key
# - BACKUP_USER: Username for backup server
# - BACKUP_HOST: Backup server hostname
# - DEST_FILE: Destination file path on backup server
# - FILE_NAME: Name of the file
# - FILE: Local file path
```

### get_dump_files
Returns an array of all dump files in the backup directory.

```bash
# Usage
files=($(get_dump_files))

# Example
if [ ${#files[@]} -eq 0 ]; then
    echo "No dump files found"
else
    echo "Found ${#files[@]} dump files"
    for file in "${files[@]}"; do
        echo "File: $file"
    done
fi
```

### get_dump_file
Returns the first dump file found in the backup directory.

```bash
# Usage
if ! latest_file=$(get_dump_file); then
    echo "No dump files available"
    exit 1
fi
echo "Latest dump file: $latest_file"
```

## Environment Variables

Required environment variables in `.env`:

```bash
# Database configuration
POSTGRES_USER=
POSTGRES_PASSWORD=
POSTGRES_HOST=
POSTGRES_PORT=
POSTGRES_DB=

# Backup configuration
BACKUP_DATABASES=db1,db2,db3  # Comma-separated list of databases to backup
POSTGRES_DUMP_PATH=/path/to/dump/directory

# SSH configuration
SSH_PRIVATE_KEY=/path/to/private/key
BACKUP_USER=username
BACKUP_HOST=backup.server.com
```

## Error Handling

All functions include error handling:
- `get_dump_file` returns error if no files are found
- `check_destination_file` exits if file already exists on backup server
- All functions use `set -e` for immediate exit on error

## Best Practices

1. Always check array length before processing:
```bash
files=($(get_dump_files))
if [ ${#files[@]} -eq 0 ]; then
    echo "No files to process"
    exit 0
fi
```

2. Use proper quoting for array elements:
```bash
for file in "${files[@]}"; do
    echo "$file"
done
```

3. Handle function return values:
```bash
if ! result=$(get_dump_file); then
    echo "Error getting dump file"
    exit 1
fi
``` 