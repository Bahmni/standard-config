## Default Bahmni configuration and data for Bahmni Standard
======================================================================

This repository holds the Bahmni Configurations for Bahmni Standard with CIEL dictionary for metadata.

This repo has been forked from Bahmni/default-config and CIEL metadata is added on top of it.

Refer Bahmni Wiki for detailed explanation of each configuration: https://bahmni.atlassian.net/wiki/spaces/BAH/pages/2392073/Implementer+s+Guide

## Docker Image Build
The docker image bahmni/standard-config is generated using Github Actions. 

In order to build the image in local you can run the following command
```shell
docker build -t bahmni/standard-config -f package/docker/Dockerfile .
```

To dockerise your implementation specific config repository, follow the steps below:
1. Copy the package/docker directory to your repository
2. Add/ remove COPY statements in Dockerfile based on the needs.
3. Run the following command after updating image repository and image name.
    > docker build -t {repository}/{image-name} -f package/docker/Dockerfile .
4. Also you can add Github Actions from `.github/workflows` directory.

## BMI gauge
A speedometer showing the patient's latest BMI, directly under the "Latest" panel of the Nutritional Values section on the registration visit page (`/bahmni/registration/#/patient/<patientUuid>/visit`).

**Where it is:** `openmrs/apps/customDisplayControl/js/customControl.js`, at the end of the file. It has two parts: the `bmiGauge` directive and a `run` block that places it on the page. No other files or libraries are involved, and no rebuild of bahmni-apps is needed.

**How it gets under the Latest panel:** registration has no extension point in that column, so the `run` block adds it.
- It only runs on registration pages, and only watches the DOM while the route is `#/patient/<uuid>/visit`.
- A `MutationObserver` looks for the `.concept-set-group` whose text mentions BMI or Nutrition, and inserts `<bmi-gauge>` right after its `<bahmni-observation>`. The patient uuid comes from the route.
- `data-bmi-gauge="1"` on the `article` marks the column as done, so only one gauge is added.
- The gauge is removed and added again when the patient changes or the panel is rebuilt. Saving the visit rebuilds the page, so the gauge reloads with the new BMI.

**Where the data comes from:** the same call as the Latest panel (`observationsService.fetch` with `scope=latest`), so both show the same BMI. `BMI Data` and `BMI Status Data` are group concepts, so the values are read from their `BMI` and `BMI Status` members. Patient age comes from `/openmrs/ws/rest/v1/person/<uuid>?v=custom:(age)`.

**Changing thresholds or colours:** edit `BMI_GAUGE_CONFIG` at the top of the directive.
- `bands`: `lower`, `upper`, `color`, the legend text in `range`, and `recordedAs` (recorded statuses that count as agreeing with the band, so no "Recorded status" line is shown).
- `dial`, `ticks`: the dial range and labelled tick marks.
- `adultAgeYears`: patients younger than this get grey bands and "Use BMI-for-age (WHO z-scores)".

After changing the file, do a hard refresh (Ctrl+Shift+R), because browsers can cache it.
