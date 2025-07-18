Loan Charge Exercise Code 

*Prerequisites 
1. Enable Person Accounts from Setup->Personal Accounts. Follow the prompts to create a new Record Type and assign it to the desired Account layouts and then re-try the readiness check.
2. Enable Custom Address Fields in Setup->User Interface

To deploy the distribution from VSCode, set the default org to the deployment destination and run:
sf project deploy start

Optional post-deployment steps within the org are:
1. In the desired profiles, enable the new custom tab 'Loans'
2. Add the custom tab to any required apps
3. Add CRUD permission for the Loans and Loan Type objects to the desired permission sets and consider which profiles should have FLS access

Assummptions made in the implementation:
1. To have an Admin Fee processed before and Interest Charge where they naturally fall on the same day, it is assumed that the Interest Charge can be moved to the next day
2. It is assumed there is only one Interest Charge per day
3. It is assumed that there will be no non-Release charges later than a month after the Release Charge, which is only being extended by 1 month.

# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
