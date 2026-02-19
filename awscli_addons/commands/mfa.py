from  os import environ

from awscli_addons.custom import Credentials_save, Config_profile_exists

DEFAULT_MFA_PROFILE_PREFIX = "mfa"
DEFAULT_SESSION_DURATION = 43200  # 12 hours


def create_session(profile_name: str = None, mfa_token: str = None, duration: int = DEFAULT_SESSION_DURATION):
    from boto3 import Session
    from botocore.exceptions import ClientError
    
    if profile_name is None:
        profile_name = environ.get("AWS_PROFILE", "default")

    session = Session(profile_name=profile_name)
    iam = session.client("iam")
    sts = session.client("sts")
    _profile = f"{DEFAULT_MFA_PROFILE_PREFIX}_{profile_name}"

    if not Config_profile_exists(".aws/credentials", _profile):
        print(f"ℹ️ Adding empty profile '{_profile}' to credentials file for future use")
        Credentials_save(creds=None, profile_name=_profile, output=False)

    try:
        username = iam.get_user()["User"]["UserName"]
        mfa_devices = iam.list_mfa_devices(UserName=username)["MFADevices"]
        if not mfa_devices:
            raise Exception("No MFA devices found for this user")
        mfa_serial = mfa_devices[0]["SerialNumber"]
        creds = sts.get_session_token(
            SerialNumber=mfa_serial,
            TokenCode=mfa_token,
            DurationSeconds=duration
        )["Credentials"]

        Credentials_save(creds=creds, profile_name=_profile)

    except ClientError as e:
        print(f"❌ AWS Error: {e}")
