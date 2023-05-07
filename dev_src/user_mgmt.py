# User managment expirement
import pickledb
import hashlib
import os
from secrets import compare_digest
from pyroboxCore import config, logger
from enum import Enum

# Loads user database. Database is plaintext but stores passwords as a hash salted by config.PASSWORD
user_db: pickledb.PickleDB = pickledb.load(
    os.path.join(config.MAIN_FILE_dir, "users.db"), True
)


class UserPermission(Enum):
    """Enum for WebUI user permissions, in Unix permission style

    Args:
        Enum (int): POSIX Octal Permission for User
    """
    NOPERMISSION = 0
    EXECUTE = 1
    WRITE = 2
    WRITE_EXECUTE = 3
    READ = 4
    READ_EXECUTE = 5
    READ_WRITE = 6
    READ_WRITE_EXECUTE = 7


class User:
    """Object for WebUI users
    """
    def __init__(self, username: str, permission: UserPermission, password: str = None):
        """Generate Object for WebUI users

        Args:
            username (str): plaintext username
            permission (UserPermission): password as a UserPermission enum
            password (str, optional): plaintext passsword (later to be hashed). Defaults to None.

        Raises:
            ValueError: User failed to create

        Returns:
            User: Object for WebUI users
        """
        # Private function
        def update_pw(self, password: str):
            """Private method to update password, not usable from outside object

            Args:
                password (str): plaintext password to be salted and hashed

            Raises:
                ValueError: Password failed to be applied at database level

            Returns:
                Int: Zero if OK
            """
            # passwords and hashed passwords are not ever assigned to the object
            try:
                salted_password = self.get_salt_pw(password)
                logger.info(f"Updating password of user {self.username}")
                user_db.set(self.username, salted_password)
                return 0
            except:
                raise ValueError

        try:
            self.username = username
            if user_db.exists(username):
                self.permission = permission
            elif password == None:
                self.permission = permission
            else:
                update_pw(self, password)
                self.set_permissions(permission)
        except ValueError as e:
            logger.error(f"User creationg error: {e}")
            return

    common_salt = hashlib.md5(
        config.PASSWORD.encode()
    ).hexdigest()  # get the MD5 has of the CLI password to use as a salt

    def get_salt_pw(self, password: str) -> str:
        return hashlib.sha256(password.encode() + self.common_salt.encode()).hexdigest()

    @classmethod
    def get_user(cls, username: str):
        if user_db.exists(username) and user_db.exists(username + "__permissions"):
            permission = UserPermission(int(user_db.get(username + "__permissions")))
            return cls(username=username, permission=permission)
        else:
            logger.error(f"User {username} does not exist")
            raise NameError

    def set_permissions(self, permission: UserPermission):
        if type(permission) != UserPermission:
            return 2
        self.permission = permission
        user_db.set(self.username + "__permissions", permission.value)
        return 0

    def reset_pw(self, old_password: str, new_password: str) -> int:
        salted_old_password = self.get_salt_pw(old_password)
        salted_new_password = self.get_salt_pw(new_password)
        if compare_digest(user_db.get(self.username), salted_old_password):
            logger.info(f"Updating password of user {self.username}")
            user_db.set(self.username, salted_new_password)
            return 0
        else:
            logger.info(f"User {self.username} password mismatch")
            return 1

    def check_creds(self, password: str) -> bool:
        salted_new_password = self.get_salt_pw(password)
        return compare_digest(user_db.get(self.username), salted_new_password)

