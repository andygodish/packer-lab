.PHONY: ubuntu2404
	
ubuntu2404:
	packer init ubuntu2404/packer.pkr.hcl
	packer build -var-file variables.pkvars.hcl ubuntu2404/packer.pkr.hcl