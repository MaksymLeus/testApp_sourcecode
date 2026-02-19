#!/usr/bin/env python3
import click

# Define the custom help flags
CONTEXT_SETTINGS = dict(help_option_names=['-h', '--help'])

__version__ = "882ae35"

@click.group(context_settings=CONTEXT_SETTINGS)
@click.version_option(__version__, '--version', '-v', 
    prog_name="awscli-addons",
    message="%(version)s"
)

def cli():
    """AWS CLI Addons - Enhance your AWS CLI experience with additional commands for MFA, role assumption, identity verification, and more."""
    pass

@cli.command("verify")
@click.option("-si","--skip-interactive", default=False, help="Skip interactive prompts so you don't need input anything")
def verify_command(skip_interactive):
    """Verify environment, AWS config, and connectivity"""
    from awscli_addons.commands.verify import run_verify
    run_verify(skip_interactive)

@cli.command("mfa")
@click.option("--profile", default=None, help="Base AWS profile")
@click.option("--mfa-code", prompt="Enter MFA code", hide_input=False, help="6-digit MFA token")

def mfa_command(profile, mfa_code):
    """Generate temporary AWS credentials using MFA"""
    from awscli_addons.commands.mfa import create_session
    create_session(profile, mfa_code)


@cli.command("assume-role")
@click.option("--role-arn", prompt=True, help="IAM Role ARN to assume")
@click.option("--session-name", default="AWSCLI-Session", help="Role session name")
@click.option("--profile", default=None, help="Base AWS profile")
def assume_role_command(role_arn, session_name, profile):
    """Assume an AWS IAM role"""
    from awscli_addons.commands.assume_role import assume
    assume(role_arn, session_name, profile)


@cli.command("whoami")
@click.option("--profile", default=None, help="AWS profile to query")
def whoami_command(profile):
    """Show AWS identity (sts get-caller-identity)"""
    from awscli_addons.commands.whoami import show
    show(profile)


@cli.command("myip")
def myip_command():
    """Show your public IP"""
    from awscli_addons.commands.myip import show
    show()


if __name__ == "__main__":
    cli()
