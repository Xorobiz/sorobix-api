use super::account_service::AccountService;
use super::contract_deployer::ContractDeploymentService;
use super::contract_service::ContractService;

pub struct ApplicationService {
    pub account_service: AccountService,
    pub contract_service: ContractService,
    pub contract_deployment_service: ContractDeploymentService,
}

impl ApplicationService {
    pub fn new() -> ApplicationService {
        ApplicationService {
            account_service: AccountService {},
            contract_service: ContractService {},
            contract_deployment_service: ContractDeploymentService {},
        }
    }
    pub fn get_account_service(&self) -> &AccountService {
        &self.account_service
    }
    pub fn get_contract_service(&self) -> &ContractService {
        &self.contract_service
    }
    pub fn get_contract_deployment_service(&self) -> &ContractDeploymentService {
        &self.contract_deployment_service
    }
}
