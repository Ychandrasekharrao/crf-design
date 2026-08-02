# SDTM Dataset Validation

## Overview
This project demonstrates validation of clinical trial datasets mapped to CDISC SDTM standards. It includes edit check logic, discrepancy reports, and compliance checks across multiple domains (DM, AE, CM, LB, VS).

## Deliverables
- **validation_reports/** → Final edit check outputs (e.g., EC-001 to EC-008)  
- **validation_scripts/** → SQL/Python scripts for automated validation  
- **discrepancy_logs/** → Records of issues flagged for medical/data review  

## Example Edit Checks
- **EC-001 (DM):** Patient ID must be unique per site → PASS  
- **EC-004 (CM):** Study Day validity with partial date handling → REVIEW  
- **EC-005 (LB):** Out-of-range lab values flagged for medical review → REVIEW  
- **EC-007 (AE/DM):** Fatal outcome requires Date of Death in DM → PASS  

## CDM Philosophy
> *"Validation ensures compliance and traceability; data issues are flagged, not cleaned."*
