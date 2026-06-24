import os
import sys
import zipfile
import tempfile
import shutil
import logging


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)
def folder_has_init(path):
    """Return True if folder contains __init__.py."""
    return os.path.isfile(os.path.join(path, "__init__.py"))
def find_folders_to_remove(root_dir):
    """
    Identify folders that must be removed:
    - Any folder (except root) that does NOT contain __init__.py
    - If a folder is removed, its children are ignored
    """
    folders_to_remove = []

    for current, dirs, files in os.walk(root_dir):
        # Skip root folder
        if current == root_dir:
            continue

        rel_path = os.path.relpath(current, root_dir)

        # If parent folder is already removed, skip children
        if any(rel_path.startswith(parent + os.sep) for parent in folders_to_remove):
            continue

        if not folder_has_init(current):
            folders_to_remove.append(rel_path)

    return sorted(folders_to_remove)


def remove_folders(root_dir, folders):
    """Remove folders from filesystem."""
    for folder in folders:
        full_path = os.path.join(root_dir, folder)
        if os.path.isdir(full_path):
            logging.info(f"Removing folder: {folder}")
            shutil.rmtree(full_path, ignore_errors=True)


def write_cleaned_file(root_dir, folders):
    """Write cleaned.txt with sorted list of removed folders."""
    cleaned_path = os.path.join(root_dir, "cleaned.txt")
    with open(cleaned_path, "w") as f:
        for folder in folders:
            f.write(folder + "\n")
    logging.info("cleaned.txt created")


def create_new_zip(original_zip, root_dir):
    """Create new zip archive with _new suffix."""
    new_zip = original_zip.replace(".zip", "_new.zip")

    with zipfile.ZipFile(new_zip, "w", zipfile.ZIP_DEFLATED) as z:
        for root, dirs, files in os.walk(root_dir):
            for file in files:
                full_path = os.path.join(root, file)
                rel_path = os.path.relpath(full_path, root_dir)
                z.write(full_path, rel_path)

    logging.info(f"New archive created: {new_zip}")


def main():
    if len(sys.argv) != 2:
        print("Usage: python clean_app.py <zip-file>")
        sys.exit(1)

    zip_file = sys.argv[1]

    if not os.path.isfile(zip_file):
        logging.error("Zip file does not exist.")
        sys.exit(1)

    # Create temp directory
    temp_dir = tempfile.mkdtemp()
    logging.info(f"Extracting to temp directory: {temp_dir}")

    # Extract zip
    with zipfile.ZipFile(zip_file, "r") as z:
        z.extractall(temp_dir)

    # Detect folders to remove
    folders_to_remove = find_folders_to_remove(temp_dir)

    # Remove folders
    remove_folders(temp_dir, folders_to_remove)

    # Write cleaned.txt
    write_cleaned_file(temp_dir, folders_to_remove)

    # Create new zip
    create_new_zip(zip_file, temp_dir)

    # Cleanup
    shutil.rmtree(temp_dir)
    logging.info("Temporary directory cleaned up")


if __name__ == "__main__":
    main()
