import os

from azure.core.exceptions import ResourceExistsError
from azure.storage.filedatalake import DataLakeServiceClient


def main() -> None:
    connection_string = os.environ.get("DATALAKE_CONNECTION_STRING")
    filesystem_name = os.environ.get("DATALAKE_FILE_SYSTEM")
    directory_name = os.environ.get("DATALAKE_DIRECTORY")

    if not connection_string:
        raise ValueError("DATALAKE_CONNECTION_STRING is required.")
    if not filesystem_name:
        raise ValueError("DATALAKE_FILE_SYSTEM is required.")
    if not directory_name:
        raise ValueError("DATALAKE_DIRECTORY is required.")

    service = DataLakeServiceClient.from_connection_string(connection_string)
    filesystem = service.get_file_system_client(filesystem_name)

    try:
        filesystem.create_file_system()
        print(f"Created ADLS filesystem: {filesystem_name}")
    except ResourceExistsError:
        print(f"ADLS filesystem already exists: {filesystem_name}")

    directory = filesystem.get_directory_client(directory_name)
    try:
        directory.create_directory()
        print(f"Created ADLS directory: {filesystem_name}/{directory_name}")
    except ResourceExistsError:
        print(f"ADLS directory already exists: {filesystem_name}/{directory_name}")


if __name__ == "__main__":
    main()
