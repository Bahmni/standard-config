'use strict';

angular.module('bahmni.common.displaycontrol.custom')
    .directive('birthCertificate', ['observationsService', 'appService', 'spinner', function (observationsService, appService, spinner) {
            var link = function ($scope) {
                console.log("inside birth certificate");
                var conceptNames = ["HEIGHT"];
                $scope.contentUrl = appService.configBaseUrl() + "/customDisplayControl/views/birthCertificate.html";
                spinner.forPromise(observationsService.fetch($scope.patient.uuid, conceptNames, "latest", undefined, $scope.visitUuid, undefined).then(function (response) {
                    $scope.observations = response.data;
                }));
            };

            return {
                restrict: 'E',
                template: '<ng-include src="contentUrl"/>',
                link: link
            }
    }]).directive('deathCertificate', ['observationsService', 'appService', 'spinner', function (observationsService, appService, spinner) {
        var link = function ($scope) {
            var conceptNames = ["WEIGHT"];
            $scope.contentUrl = appService.configBaseUrl() + "/customDisplayControl/views/deathCertificate.html";
            spinner.forPromise(observationsService.fetch($scope.patient.uuid, conceptNames, "latest", undefined, $scope.visitUuid, undefined).then(function (response) {
                $scope.observations = response.data;
            }));
        };

        return {
            restrict: 'E',
            link: link,
            template: '<ng-include src="contentUrl"/>'
        }
    }]).directive('customTreatmentChart', ['appService', 'treatmentConfig', 'TreatmentService', 'spinner', '$q', function (appService, treatmentConfig, treatmentService, spinner, $q) {
    var link = function ($scope) {
        var Constants = Bahmni.Clinical.Constants;
        var days = [
            'Sunday',
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday'
        ];
        $scope.contentUrl = appService.configBaseUrl() + "/customDisplayControl/views/customTreatmentChart.html";

        $scope.atLeastOneDrugForDay = function (day) {
            var atLeastOneDrugForDay = false;
            $scope.ipdDrugOrders.getIPDDrugs().forEach(function (drug) {
                if (drug.isActiveOnDate(day.date)) {
                    atLeastOneDrugForDay = true;
                }
            });
            return atLeastOneDrugForDay;
        };

        $scope.getVisitStopDateTime = function () {
            return $scope.visitSummary.stopDateTime || Bahmni.Common.Util.DateUtil.now();
        };

        $scope.getStatusOnDate = function (drug, date) {
            var activeDrugOrders = _.filter(drug.orders, function (order) {
                if ($scope.config.frequenciesToBeHandled.indexOf(order.getFrequency()) !== -1) {
                    return getStatusBasedOnFrequency(order, date);
                } else {
                    return drug.getStatusOnDate(date) === 'active';
                }
            });
            if (activeDrugOrders.length === 0) {
                return 'inactive';
            }
            if (_.every(activeDrugOrders, function (order) {
                    return order.getStatusOnDate(date) === 'stopped';
                })) {
                return 'stopped';
            }
            return 'active';
        };

        var getStatusBasedOnFrequency = function (order, date) {
            var activeBetweenDate = order.isActiveOnDate(date);
            var frequencies = order.getFrequency().split(",").map(function (day) {
                return day.trim();
            });
            var dayNumber = moment(date).day();
            return activeBetweenDate && frequencies.indexOf(days[dayNumber]) !== -1;
        };

        var init = function () {
            var getToDate = function () {
                return $scope.visitSummary.stopDateTime || Bahmni.Common.Util.DateUtil.now();
            };

            var programConfig = appService.getAppDescriptor().getConfigValue("program") || {};

            var startDate = null, endDate = null, getEffectiveOrdersOnly = false;
            if (programConfig.showDetailsWithinDateRange) {
                startDate = $stateParams.dateEnrolled;
                endDate = $stateParams.dateCompleted;
                if (startDate || endDate) {
                    $scope.config.showOtherActive = false;
                }
                getEffectiveOrdersOnly = true;
            }

            return $q.all([treatmentConfig(), treatmentService.getPrescribedAndActiveDrugOrders($scope.config.patientUuid, $scope.config.numberOfVisits,
                $scope.config.showOtherActive, $scope.config.visitUuids || [], startDate, endDate, getEffectiveOrdersOnly)])
                .then(function (results) {
                    var config = results[0];
                    var drugOrderResponse = results[1].data;
                    var createDrugOrderViewModel = function (drugOrder) {
                        return Bahmni.Clinical.DrugOrderViewModel.createFromContract(drugOrder, config);
                    };
                    for (var key in drugOrderResponse) {
                        drugOrderResponse[key] = drugOrderResponse[key].map(createDrugOrderViewModel);
                    }

                    var groupedByVisit = _.groupBy(drugOrderResponse.visitDrugOrders, function (drugOrder) {
                        return drugOrder.visit.startDateTime;
                    });
                    var treatmentSections = [];

                    for (var key in groupedByVisit) {
                        var values = Bahmni.Clinical.DrugOrder.Util.mergeContinuousTreatments(groupedByVisit[key]);
                        treatmentSections.push({visitDate: key, drugOrders: values});
                    }
                    if (!_.isEmpty(drugOrderResponse[Constants.otherActiveDrugOrders])) {
                        var mergedOtherActiveDrugOrders = Bahmni.Clinical.DrugOrder.Util.mergeContinuousTreatments(drugOrderResponse[Constants.otherActiveDrugOrders]);
                        treatmentSections.push({
                            visitDate: Constants.otherActiveDrugOrders,
                            drugOrders: mergedOtherActiveDrugOrders
                        });
                    }
                    $scope.treatmentSections = treatmentSections;
                    if ($scope.visitSummary) {
                        $scope.ipdDrugOrders = Bahmni.Clinical.VisitDrugOrder.createFromDrugOrders(drugOrderResponse.visitDrugOrders, $scope.visitSummary.startDateTime, getToDate());
                    }
                });
        };
        spinner.forPromise(init());
    };

    return {
        restrict: 'E',
        link: link,
        scope: {
            config: "=",
            visitSummary: '='
        },
        template: '<ng-include src="contentUrl"/>'
    }
}]).directive('patientAppointmentsDashboard', ['$http', '$q', '$window','appService', 'virtualConsultService', function ($http, $q, $window, appService, virtualConsultService) {
    var link = function ($scope) {
        $scope.contentUrl = appService.configBaseUrl() + "/customDisplayControl/views/patientAppointmentsDashboard.html";
        var getUpcomingAppointments = function () {
            var params = {
                q: "bahmni.sqlGet.upComingAppointments",
                v: "full",
                patientUuid: $scope.patient.uuid
            };
            return $http.get('/openmrs/ws/rest/v1/bahmnicore/sql', {
                method: "GET",
                params: params,
                withCredentials: true
            });
        };
        var getPastAppointments = function () {
            var params = {
                q: "bahmni.sqlGet.pastAppointments",
                v: "full",
                patientUuid: $scope.patient.uuid
            };
            return $http.get('/openmrs/ws/rest/v1/bahmnicore/sql', {
                method: "GET",
                params: params,
                withCredentials: true
            });
        };

        var transformDate = function (dateTimeArray) {
            var dateTime = dateTimeArray.slice();
            dateTime[1] = dateTime[1] - 1
            return Bahmni.Common.Util.DateUtil.formatDateWithoutTimeToLocal(dateTime)
        }

        var transformTime = function (dateTime) {
            return Bahmni.Common.Util.DateUtil.formatTimeToLocal(dateTime);
        }

        var getAppointmentDateAndSlot = function (startTimeInMillseconds, endTimeInMillseconds) {
            let appointmentStartDate = transformDate(startTimeInMillseconds);
            let timeSlot = transformTime(startTimeInMillseconds) + " - " + transformTime(endTimeInMillseconds) ;
            return [appointmentStartDate, timeSlot];
        }

        $q.all([getUpcomingAppointments(), getPastAppointments()]).then(function (response) {
            $scope.upcomingAppointments = response[0].data;
            $scope.upcomingAppointmentsUUIDs = [];
            $scope.teleconsultationAppointments = [];
            $scope.upcomingAppointmentsLinks = [];
            for (var i=0; i<$scope.upcomingAppointments.length; i++) {
                $scope.upcomingAppointmentsUUIDs[i] = $scope.upcomingAppointments[i].uuid;
                $scope.teleconsultationAppointments[i] = 'Virtual' === $scope.upcomingAppointments[i].DASHBOARD_APPOINTMENTS_KIND;
                delete $scope.upcomingAppointments[i].uuid;
                const [date, timeSlot] = getAppointmentDateAndSlot($scope.upcomingAppointments[i].DASHBOARD_APPOINTMENTS_START_DATE_IN_UTC_KEY, $scope.upcomingAppointments[i].DASHBOARD_APPOINTMENTS_END_DATE_IN_UTC_KEY);
                delete $scope.upcomingAppointments[i].DASHBOARD_APPOINTMENTS_START_DATE_IN_UTC_KEY;
                delete $scope.upcomingAppointments[i].DASHBOARD_APPOINTMENTS_END_DATE_IN_UTC_KEY;
                delete $scope.upcomingAppointments[i].DASHBOARD_APPOINTMENTS_START_DATE_KEY;
                delete $scope.upcomingAppointments[i].DASHBOARD_APPOINTMENTS_END_DATE_KEY;
                $scope.upcomingAppointments[i].DASHBOARD_APPOINTMENTS_DATE_KEY = date;
                $scope.upcomingAppointments[i].DASHBOARD_APPOINTMENTS_SLOT_KEY = timeSlot;
                $scope.upcomingAppointmentsLinks[i] = $scope.upcomingAppointments[i].tele_health_video_link || "";
                delete $scope.upcomingAppointments[i].DASHBOARD_APPOINTMENTS_KIND;
                delete $scope.upcomingAppointments[i].tele_health_video_link;
            }
            $scope.upcomingAppointmentsHeadings = _.keys($scope.upcomingAppointments[0]);
            $scope.pastAppointments = response[1].data;
            for (let i = 0; i < $scope.pastAppointments.length; i++) {
                const [date, timeSlot] = getAppointmentDateAndSlot($scope.pastAppointments[i].DASHBOARD_APPOINTMENTS_START_DATE_IN_UTC_KEY, $scope.pastAppointments[i].DASHBOARD_APPOINTMENTS_END_DATE_IN_UTC_KEY);
                delete $scope.pastAppointments[i].DASHBOARD_APPOINTMENTS_START_DATE_IN_UTC_KEY;
                delete $scope.pastAppointments[i].DASHBOARD_APPOINTMENTS_END_DATE_IN_UTC_KEY;
                $scope.pastAppointments[i].DASHBOARD_APPOINTMENTS_DATE_KEY = date;
                $scope.pastAppointments[i].DASHBOARD_APPOINTMENTS_SLOT_KEY = timeSlot;
            }
            $scope.pastAppointmentsHeadings = _.keys($scope.pastAppointments[0]);
        });

        $scope.goToListView = function () {
            $window.open('/appointments/#/home/manage/appointments/list');
        };
        $scope.openJitsiMeet = function (appointmentIndex) {
            var uuid = $scope.upcomingAppointmentsUUIDs[appointmentIndex];
            var link = $scope.upcomingAppointmentsLinks[appointmentIndex];
            virtualConsultService.launchMeeting(uuid, link);
        };
        $scope.showJoinTeleconsultationOption = function (appointmentIndex) {
            return $scope.upcomingAppointments[appointmentIndex].DASHBOARD_APPOINTMENTS_STATUS_KEY == 'Scheduled' &&
                    $scope.teleconsultationAppointments[appointmentIndex];
        }
    };
    return {
        restrict: 'E',
        link: link,
        scope: {
            patient: "=",
            section: "="
        },
        template: '<ng-include src="contentUrl"/>'
    };
}]);

// BMI speedometer shown under the "Latest" panel on the registration visit page.
// See "BMI gauge" in the README of this repo. Change thresholds and colours in BMI_GAUGE_CONFIG.
angular.module('bahmni.common.displaycontrol.custom')
    .directive('bmiGauge', ['observationsService', '$http', '$q', '$filter', '$timeout', '$window', function (observationsService, $http, $q, $filter, $timeout, $window) {
        var BMI_GAUGE_CONFIG = {
            // A value is in a band when lower <= BMI < upper. null means no limit on that side.
            bands: [
                {name: 'Underweight', lower: null, upper: 18.5, color: '#2F80ED', range: '< 18.5', recordedAs: ['underweight']},
                {name: 'Normal weight', lower: 18.5, upper: 25, color: '#27AE60', range: '18.5 - 24.9', recordedAs: ['normal weight', 'normal']},
                {name: 'Overweight', lower: 25, upper: 30, color: '#F2C94C', range: '25.0 - 29.9', recordedAs: ['overweight']},
                {name: 'Obese', lower: 30, upper: 35, color: '#F2994A', range: '30.0 - 34.9', recordedAs: ['obese']},
                {name: 'Extremely Obese', lower: 35, upper: null, color: '#EB5757', range: '>= 35.0', recordedAs: ['extremely obese']}
            ],
            dial: {min: 10, max: 45},
            ticks: [18.5, 25, 30, 35],
            greyColor: '#C9CED6',
            textOnBandColor: '#111111',
            adultAgeYears: 18,
            needleAnimationMs: 700,
            // Same concepts the "Latest" panel asks for. BMI Data and BMI Status Data are groups
            // holding BMI and BMI Status (see obscalculator/BahmniObsValueCalculator.groovy).
            requestConcepts: ['BMI Data', 'BMI Status Data'],
            valueConcepts: ['bmi', 'bmi data'],
            statusConcepts: ['bmi status', 'bmi status data']
        };

        var CENTER_X = 150;
        var CENTER_Y = 150;
        var RADIUS = 105;
        var ARC_WIDTH = 26;

        var fraction = function (value) {
            var dial = BMI_GAUGE_CONFIG.dial;
            var clamped = Math.min(dial.max, Math.max(dial.min, value));
            return (clamped - dial.min) / (dial.max - dial.min);
        };

        var pointAt = function (value, radius) {
            var radians = Math.PI * (1 - fraction(value));
            return {
                x: +(CENTER_X + radius * Math.cos(radians)).toFixed(2),
                y: +(CENTER_Y - radius * Math.sin(radians)).toFixed(2)
            };
        };

        var buildArcs = function (isGrey) {
            var dial = BMI_GAUGE_CONFIG.dial;
            return BMI_GAUGE_CONFIG.bands.map(function (band) {
                var from = pointAt(band.lower === null ? dial.min : band.lower, RADIUS);
                var to = pointAt(band.upper === null ? dial.max : band.upper, RADIUS);
                return {
                    d: 'M ' + from.x + ' ' + from.y + ' A ' + RADIUS + ' ' + RADIUS + ' 0 0 1 ' + to.x + ' ' + to.y,
                    color: isGrey ? BMI_GAUGE_CONFIG.greyColor : band.color
                };
            });
        };

        var buildTicks = function () {
            return BMI_GAUGE_CONFIG.ticks.map(function (tick) {
                var inner = pointAt(tick, RADIUS - ARC_WIDTH / 2 - 3);
                var outer = pointAt(tick, RADIUS + ARC_WIDTH / 2 + 3);
                var label = pointAt(tick, RADIUS + ARC_WIDTH / 2 + 14);
                return {x1: inner.x, y1: inner.y, x2: outer.x, y2: outer.y, labelX: label.x, labelY: label.y + 4, label: String(tick)};
            });
        };

        var bandFor = function (value) {
            return BMI_GAUGE_CONFIG.bands.filter(function (band) {
                return (band.lower === null || value >= band.lower) && (band.upper === null || value < band.upper);
            })[0];
        };

        // Flattens an observation tree, so grouped and flat responses are read the same way.
        var flatten = function (observations, parent, result) {
            (observations || []).forEach(function (obs) {
                if (!obs || obs.voided) {
                    return;
                }
                var entry = {
                    name: String((obs.concept && obs.concept.name) || obs.conceptFSN || '').toLowerCase(),
                    value: obs.value,
                    date: obs.observationDateTime || obs.obsDatetime || obs.encounterDateTime || (parent && parent.date),
                    encounterUuid: obs.encounterUuid || (parent && parent.encounterUuid)
                };
                result.push(entry);
                flatten(obs.groupMembers, entry, result);
            });
            return result;
        };

        var timestamp = function (date) {
            var time = new Date(date).getTime();
            return isNaN(time) ? 0 : time;
        };

        var latestFirst = function (a, b) {
            return timestamp(b.date) - timestamp(a.date);
        };

        var isNumeric = function (value) {
            return (typeof value === 'number' || typeof value === 'string') && value !== '' && isFinite(value);
        };

        var statusText = function (value) {
            if (value && typeof value === 'object') {
                return value.name && value.name.name ? value.name.name : (value.displayString || value.display || value.name || null);
            }
            return value || null;
        };

        var readBmi = function (observations) {
            var all = flatten(observations, null, []);
            var values = all.filter(function (entry) {
                return BMI_GAUGE_CONFIG.valueConcepts.indexOf(entry.name) !== -1 && isNumeric(entry.value);
            }).sort(latestFirst);
            if (!values.length) {
                return null;
            }
            var latest = values[0];
            var statuses = all.filter(function (entry) {
                return BMI_GAUGE_CONFIG.statusConcepts.indexOf(entry.name) !== -1 &&
                    entry.encounterUuid === latest.encounterUuid && statusText(entry.value);
            }).sort(latestFirst);
            return {
                value: parseFloat(latest.value),
                date: latest.date,
                recordedStatus: statuses.length ? String(statusText(statuses[0].value)) : null
            };
        };

        var link = function ($scope, element) {
            var requestNumber = 0;
            var animationFrame = null;

            $scope.bands = BMI_GAUGE_CONFIG.bands;
            $scope.ticks = buildTicks();
            $scope.textOnBandColor = BMI_GAUGE_CONFIG.textOnBandColor;
            $scope.greyColor = BMI_GAUGE_CONFIG.greyColor;
            $scope.state = 'loading';

            var stopAnimation = function () {
                if (animationFrame !== null) {
                    $window.cancelAnimationFrame(animationFrame);
                    animationFrame = null;
                }
            };

            var moveNeedle = function (targetAngle) {
                var needle = element[0].querySelector('.bmi-gauge-needle');
                if (!needle) {
                    return;
                }
                var rotate = function (angle) {
                    needle.setAttribute('transform', 'rotate(' + angle.toFixed(2) + ' ' + CENTER_X + ' ' + CENTER_Y + ')');
                };
                var reducedMotion = $window.matchMedia && $window.matchMedia('(prefers-reduced-motion: reduce)').matches;
                stopAnimation();
                if (reducedMotion || !$window.requestAnimationFrame) {
                    rotate(targetAngle);
                    return;
                }
                var start = null;
                var step = function (now) {
                    start = start === null ? now : start;
                    var progress = Math.min(1, (now - start) / BMI_GAUGE_CONFIG.needleAnimationMs);
                    rotate(targetAngle * (1 - Math.pow(1 - progress, 3)));
                    animationFrame = progress < 1 ? $window.requestAnimationFrame(step) : null;
                };
                animationFrame = $window.requestAnimationFrame(step);
            };

            var show = function (bmi, age) {
                var isKnownAdult = isNumeric(age) && age >= BMI_GAUGE_CONFIG.adultAgeYears;
                var band = isKnownAdult ? bandFor(bmi.value) : null;
                var valueText = bmi.value.toFixed(2);
                var dateText = $filter('date')(bmi.date, 'd MMM yyyy');
                var recorded = bmi.recordedStatus ? bmi.recordedStatus.toLowerCase() : null;

                $scope.arcs = buildArcs(!band);
                $scope.valueText = valueText;
                $scope.dateText = dateText;
                $scope.band = band;
                $scope.ageNote = isKnownAdult ? null : (isNumeric(age) ? 'Use BMI-for-age (WHO z-scores)' : 'Age unavailable: BMI band not shown');
                $scope.recordedStatus = recorded && !(band && band.recordedAs.indexOf(recorded) !== -1) ? bmi.recordedStatus : null;
                $scope.ariaLabel = 'BMI ' + valueText + ', ' + (band ? band.name : $scope.ageNote) + ', recorded ' + dateText;
                $scope.state = 'ready';
                $timeout(function () {
                    moveNeedle(fraction(bmi.value) * 180);
                }, 0, false);
            };

            var load = function (patientUuid) {
                var thisRequest = ++requestNumber;
                stopAnimation();
                if (!patientUuid) {
                    $scope.state = 'empty';
                    return;
                }
                $scope.state = 'loading';
                var observations = observationsService.fetch(patientUuid, BMI_GAUGE_CONFIG.requestConcepts, 'latest');
                var person = $http.get('/openmrs/ws/rest/v1/person/' + encodeURIComponent(patientUuid), {
                    params: {v: 'custom:(age)'},
                    withCredentials: true
                }).then(function (response) {
                    return response.data && response.data.age;
                }, function () {
                    return null;
                });
                $q.all([observations, person]).then(function (results) {
                    if (thisRequest !== requestNumber) {
                        return;
                    }
                    var bmi = readBmi(results[0].data);
                    if (bmi) {
                        show(bmi, results[1]);
                    } else {
                        $scope.state = 'empty';
                    }
                }, function () {
                    if (thisRequest === requestNumber) {
                        $scope.state = 'error';
                    }
                });
            };

            $scope.$watch('patientUuid', load);
            $scope.$on('$destroy', function () {
                requestNumber++;
                stopAnimation();
            });
        };

        return {
            restrict: 'E',
            scope: {patientUuid: '='},
            link: link,
            template: [
                '<section class="block bmi-gauge" style="margin-top:10px;">',
                '<h2 class="section-title">BMI</h2>',
                '<div style="padding:10px;text-align:center;">',
                '<p ng-if="state === \'loading\'" style="margin:10px 0;color:#666;">Loading BMI...</p>',
                '<p ng-if="state === \'empty\'" class="bmi-gauge-empty" style="margin:10px 0;">No BMI recorded</p>',
                '<p ng-if="state === \'error\'" class="bmi-gauge-error" style="margin:10px 0;">Could not load BMI</p>',
                '<div ng-if="state === \'ready\'">',
                '<svg class="bmi-gauge-dial" viewBox="0 0 300 200" role="img" ng-attr-aria-label="{{ariaLabel}}" style="display:block;width:100%;max-width:340px;margin:0 auto;">',
                '<path ng-repeat="arc in arcs" class="bmi-gauge-arc" ng-attr-d="{{arc.d}}" ng-attr-stroke="{{arc.color}}" fill="none" stroke-width="26"></path>',
                '<g ng-repeat="tick in ticks">',
                '<line ng-attr-x1="{{tick.x1}}" ng-attr-y1="{{tick.y1}}" ng-attr-x2="{{tick.x2}}" ng-attr-y2="{{tick.y2}}" stroke="#444" stroke-width="1.5"></line>',
                '<text ng-attr-x="{{tick.labelX}}" ng-attr-y="{{tick.labelY}}" text-anchor="middle" font-size="11" fill="#444">{{tick.label}}</text>',
                '</g>',
                '<g class="bmi-gauge-needle" transform="rotate(0 150 150)"><polygon points="62,150 150,145 150,155" fill="#333"></polygon></g>',
                '<circle cx="150" cy="150" r="8" fill="#333"></circle>',
                '<text class="bmi-gauge-value" x="150" y="190" text-anchor="middle" font-size="26" font-weight="700" fill="#222">{{valueText}}</text>',
                '</svg>',
                '<div ng-if="band" class="bmi-gauge-band" ng-style="{\'background-color\': band.color, \'color\': textOnBandColor}" style="display:inline-block;margin-top:4px;padding:2px 12px;border-radius:12px;font-weight:600;">{{band.name}}</div>',
                '<div ng-if="ageNote" class="bmi-gauge-age-note" style="margin-top:4px;font-weight:600;">{{ageNote}}</div>',
                '<div ng-if="recordedStatus" class="bmi-gauge-recorded-status" style="margin-top:4px;font-size:12px;color:#555;">Recorded status: {{recordedStatus}}</div>',
                '<div class="bmi-gauge-date" style="margin-top:4px;font-size:12px;color:#555;">Recorded: {{dateText}}</div>',
                '<ul class="bmi-gauge-legend" style="list-style:none;margin:8px 0 0;padding:0;text-align:left;font-size:12px;">',
                '<li ng-repeat="legendBand in bands" style="margin:2px 0;">',
                '<span ng-style="{\'background-color\': band || !ageNote ? legendBand.color : greyColor}" style="display:inline-block;width:10px;height:10px;margin-right:6px;border-radius:2px;"></span>',
                '{{legendBand.name}} ({{legendBand.range}})',
                '</li>',
                '</ul>',
                '</div>',
                '</div>',
                '</section>'
            ].join('')
        };
    }])
    // Registration has no extension point in the "Latest" column, so the gauge is placed here.
    // Debug info is off in production builds, so element.scope() cannot be used to find a page scope.
    .run(['$rootScope', '$compile', '$location', '$timeout', '$window', function ($rootScope, $compile, $location, $timeout, $window) {
        if ($window.location.pathname.indexOf('/registration') === -1 || !$window.MutationObserver) {
            return;
        }

        var VISIT_ROUTE = /^\/patient\/([^\/]+)\/visit$/;
        var MARKER = 'data-bmi-gauge';
        var current = null;
        var observer = null;
        var pending = null;

        var removeGauge = function () {
            if (current) {
                current.scope.$destroy();
                current.element.remove();
                current.article.removeAttribute(MARKER);
                current = null;
            }
        };

        // Finds the Nutritional Values "Latest" panel by content, never by its position on the page.
        var findPanel = function () {
            var groups = $window.document.querySelectorAll('form.visit-patient .concept-set-group');
            for (var i = 0; i < groups.length; i++) {
                var panel = groups[i].querySelector('article.obs-section > bahmni-observation');
                if (panel && /\bBMI\b|nutrition/i.test(groups[i].textContent)) {
                    return panel;
                }
            }
            return null;
        };

        var placeGauge = function () {
            pending = null;
            var route = VISIT_ROUTE.exec($location.path());
            if (!route) {
                removeGauge();
                return;
            }
            var document = $window.document.documentElement;
            if (current && current.patientUuid === route[1] && document.contains(current.panel)) {
                return;
            }
            removeGauge();
            var panel = findPanel();
            if (!panel || panel.parentNode.getAttribute(MARKER)) {
                return;
            }
            var scope = $rootScope.$new();
            scope.bmiGaugePatientUuid = route[1];
            var element = $compile('<bmi-gauge patient-uuid="bmiGaugePatientUuid"></bmi-gauge>')(scope);
            angular.element(panel).after(element);
            panel.parentNode.setAttribute(MARKER, '1');
            current = {patientUuid: route[1], panel: panel, article: panel.parentNode, element: element, scope: scope};
            $rootScope.$digest();
        };

        var schedule = function () {
            if (pending === null) {
                pending = $timeout(placeGauge, 100, false);
            }
        };

        var onRouteChange = function () {
            if (VISIT_ROUTE.test($location.path())) {
                if (!observer) {
                    observer = new $window.MutationObserver(schedule);
                    observer.observe($window.document.body, {childList: true, subtree: true});
                }
            } else if (observer) {
                observer.disconnect();
                observer = null;
            }
            schedule();
        };

        $rootScope.$on('$locationChangeSuccess', onRouteChange);
        onRouteChange();
    }]);
