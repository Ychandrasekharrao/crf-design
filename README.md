# CRF Design

## Overview
This repository demonstrates Case Report Form (CRF) design and documentation for clinical data management.  
It includes eCRF, annotated CRF (aCRF), specification sheets, and edit check logic.

## Deliverables
- **crf_artifacts/** → eCRF, aCRF, spec sheet, edit check list  
- **edit_checks/** → Edit check definitions and logic  
- **sdtm_mapping/** → Mapping specifications from CRF to SDTM domains  

## Example Edit Checks
- **EC-001 (DM):** Patient ID must be unique per site  
- **EC-003 (DM):** Age must meet protocol eligibility (placeholder 18–100)  
- **EC-006 (AE):** AE end date must not precede start date  
- **EC-007 (AE/DM):** Fatal outcome requires Date of Death in DM  

## CDM Philosophy
> *"CRF design ensures traceability from data collection to SDTM mapping, enabling clean and compliant datasets."*
