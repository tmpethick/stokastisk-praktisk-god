
# Stokastisk Praktisk God

This repository is the codebase for a project simulating a supermarket as a queueing system.

## Usage

The plots and data used in the different sections can be reproduced using the different drivers in [`Drivers/`](../master/Drivers/).
The mapping between below provides the connection between a driver and its corresponding section.


| Driver                        | Section                  | Description                              |
| ----------------------------- | ------------------------ | ---------------------------------------- |
| `driverVerification.m`        | **Verification**         | Calculates results that are compared with analytic results. |
| `driverMultipleQueueSanity.m` | **Verification**         | Varies server number.                    |
| `driverVanilla.m`             | **Experimental Design**  |                                          |
| `driverStrategyComparison.m`  | **Experimental Design**  |                                          |
| `driverVarianceReduction.m`   | **Statistical Analysis** |                                          |
