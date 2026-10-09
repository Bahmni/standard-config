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

        const zeroIndexMonth = (dateTimeArray) => {
            const zeroIndexedMonth = dateTimeArray.slice();
            zeroIndexedMonth[1] -= 1;
            return zeroIndexedMonth;
        };

        const transformDate = (dateTimeArray) => {
            return Bahmni.Common.Util.DateUtil.formatDateWithoutTimeToLocal(
                zeroIndexMonth(dateTimeArray),
            );
        };

        const transformTime = (dateTimeArray) => {
            return Bahmni.Common.Util.DateUtil.formatTimeToLocal(
                zeroIndexMonth(dateTimeArray),
            );
        };

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

// Vaidra doorway — launch with visit context; on return, claim write code → save Consultation Note.
angular.module('bahmni.common.displaycontrol.custom')
    .directive('vaidraVisitLaunch', ['$window', '$location', '$state', 'appService', '$rootScope', '$http', '$q', 'configurations',
        function ($window, $location, $state, appService, $rootScope, $http, $q, configurations) {
            var C = Bahmni.Common.Constants;
            var NOTE = C.consultationNoteConceptName;
            var CHART_REQUEST = 'vaidra-ehr-chart-request';
            var CHART_REPLY = 'vaidra-ehr-chart';

            function fail(message) {
                return $q.reject({ message: message });
            }

            function originOf(url) {
                try { return new URL(url).origin; } catch (e) { return ''; }
            }

            function readTicket(win, loc) {
                try {
                    if (loc && loc.search && loc.search().vaidraWriteTicket) return loc.search().vaidraWriteTicket;
                    var q = new URLSearchParams(win.location.search || '').get('vaidraWriteTicket');
                    if (q) return q;
                    var m = /[?&]vaidraWriteTicket=([^&]+)/.exec(win.location.hash || '');
                    return m ? decodeURIComponent(m[1]) : null;
                } catch (e) { return null; }
            }

            // Reload with a clean URL. $state.reload can run before Angular commits
            // $location.replace, causing the spent one-time ticket to be claimed again.
            function clearTicket(win, loc) {
                try {
                    var url = new URL(win.location.href);
                    var changed = url.searchParams.has('vaidraWriteTicket');
                    url.searchParams.delete('vaidraWriteTicket');

                    var hash = url.hash || '';
                    var queryAt = hash.indexOf('?');
                    if (queryAt !== -1) {
                        var hashParams = new URLSearchParams(hash.slice(queryAt + 1));
                        if (hashParams.has('vaidraWriteTicket')) {
                            changed = true;
                            hashParams.delete('vaidraWriteTicket');
                            url.hash = hash.slice(0, queryAt) +
                                (hashParams.toString() ? '?' + hashParams.toString() : '');
                        }
                    }
                    if (changed) {
                        win.location.replace(url.toString());
                        return true;
                    }
                    if (loc && loc.search && loc.search().vaidraWriteTicket) {
                        loc.search('vaidraWriteTicket', null).replace();
                    }
                } catch (e) { /* ignore */ }
                return false;
            }

            function cachedNoteUuid() {
                var note = configurations.consultationNoteConcept && configurations.consultationNoteConcept();
                return note && note.uuid;
            }

            function lookupConceptUuid(name) {
                return $http.get(C.conceptSearchByFullNameUrl, {
                    params: { name: name, v: 'custom:(uuid)' }
                }).then(function (res) {
                    var row = res.data && res.data.results && res.data.results[0];
                    return (row && row.uuid) || null;
                }, function () { return null; });
            }

            function resolveConceptUuid(names) {
                var list = names && names.length ? names : [NOTE];
                var cached = cachedNoteUuid();
                if (cached && list.indexOf(NOTE) !== -1) return $q.when(cached);
                return list.reduce(function (chain, name) {
                    return chain.then(function (found) {
                        return found || (name === NOTE && cached) || lookupConceptUuid(name);
                    });
                }, $q.when(null));
            }

            function encounterName(e) {
                var t = e && e.encounterType;
                if (!t) return '';
                return (typeof t === 'string' ? t : (t.display || t.name || '')).toString();
            }

            function pickEncounter(encounters) {
                var open = (encounters || []).filter(function (e) { return e.uuid && !e.voided; });
                var consult = open.filter(function (e) { return /consultation/i.test(encounterName(e)); });
                var pool = consult.length ? consult : open;
                return pool.length ? pool[pool.length - 1].uuid : null;
            }

            function resolveEncounterUuid(visitUuid, preferred) {
                if (preferred) return $q.when(preferred);
                var slim = 'custom:(uuid,encounters:(uuid,voided,encounterType:(uuid,display,name)))';
                var url = C.visitUrl + '/' + encodeURIComponent(visitUuid);
                return $http.get(url, { params: { v: slim } }).then(function (res) {
                    return pickEncounter(res.data && res.data.encounters);
                }, function () {
                    return $http.get(url, { params: { v: 'full' } }).then(function (res) {
                        return pickEncounter(res.data && res.data.encounters);
                    });
                });
            }

            function dataOf(req) {
                return req.then(function (r) { return r.data; }, angular.noop);
            }

            function prefetchChart(patientUuid, visitUuid) {
                var enc = encodeURIComponent(patientUuid);
                return $q.all({
                    patient: dataOf($http.get(C.RESTWS_V1 + '/patient/' + enc, { params: { v: 'full' } })),
                    observations: visitUuid ? dataOf($http.get(C.observationsUrl, {
                        params: { visitUuid: visitUuid, patient: patientUuid }
                    })) : $q.when(null),
                    diagnoses: dataOf($http.get(C.bahmniDiagnosisUrl, { params: { patientUuid: patientUuid } })),
                    medications: dataOf($http.get(C.bahmniDrugOrderUrl, { params: { patientUuid: patientUuid } })),
                    allergies: $http.get(C.RESTWS_V1 + '/patient/' + enc + '/allergy').then(function (r) {
                        return r && r.status === 204 ? null : (r && r.data);
                    }, angular.noop),
                    visit: visitUuid ? dataOf($http.get(C.visitUrl + '/' + encodeURIComponent(visitUuid), {
                        params: { v: 'full' }
                    })) : $q.when(null)
                }).then(null, function () { return null; });
            }

            function ticketIsSpent(err, claimed) {
                if (claimed) return true;
                var status = err && err.status;
                return status === 410 || status === 404;
            }

            function explainError(err, apiBase, claimed) {
                var status = err && err.status;
                var retry = ticketIsSpent(err, claimed)
                    ? ' End the visit again from Vaidra to retry.'
                    : ' Refresh this page to retry the save.';
                if (status === -1 || status === 0 || (err && err.message === 'Network Error')) {
                    if (location.protocol === 'https:' && /^http:\/\//i.test(apiBase || '')) {
                        return 'Cannot reach Vaidra. Refresh this page to retry the save.';
                    }
                    return 'Cannot reach Vaidra. Refresh this page to retry the save.';
                }
                var body = err && err.data && (err.data.message || err.data.error || err.data.exception);
                if (Array.isArray(body)) body = body.join('; ');
                if (body && typeof body === 'object') body = body.message || body.detail || null;
                if (typeof body === 'string' && body.trim()) {
                    return /retry/i.test(body) ? body : body.replace(/[. ]*$/, '') + '.' + retry;
                }
                if (err && err.message) {
                    return /retry/i.test(err.message) ? err.message : err.message.replace(/[. ]*$/, '') + '.' + retry;
                }
                return (status ? 'Could not save note (HTTP ' + status + ').' : 'Could not save note.') + retry;
            }

            function link($scope) {
                $scope.contentUrl = appService.configBaseUrl() + '/customDisplayControl/views/vaidraVisitLaunch.html';
                var closed = $scope.visitSummary && $scope.visitSummary.stopDateTime;
                $scope.canLaunch = !!$scope.visitUuid && !closed;
                $scope.writeStatus = null;
                $scope.writeMessage = '';

                var cfg = $scope.config || {};
                var webBase = (cfg.vaidraWebBaseUrl || '').replace(/\/$/, '');
                var apiBase = (cfg.vaidraApiBaseUrl || '').replace(/\/$/, '');
                var configuredSite = (cfg.vaidraSiteId || '').trim();
                var siteId = (configuredSite && configuredSite.toLowerCase() !== 'bahmni')
                    ? configuredSite
                    : (($window.location.host || '').trim());
                var vaidraOrigin = originOf(webBase);

                var chart = null, chartReady = false, waiters = [], prefetchStarted = false;
                function publishChart(next) {
                    chart = next;
                    chartReady = true;
                    waiters.splice(0).forEach(function (fn) { fn(); });
                }
                function ensureChart() {
                    if (prefetchStarted || !$scope.patient || !$scope.patient.uuid) return;
                    prefetchStarted = true;
                    prefetchChart($scope.patient.uuid, $scope.visitUuid).then(publishChart);
                }
                function onChartRequest(event) {
                    if (!vaidraOrigin || event.origin !== vaidraOrigin) return;
                    if (!event.data || event.data.type !== CHART_REQUEST || !event.source) return;
                    var reply = function () {
                        event.source.postMessage({ type: CHART_REPLY, v: 1, chart: chart }, event.origin);
                    };
                    chartReady ? reply() : waiters.push(reply);
                }
                $window.addEventListener('message', onChartRequest);
                $scope.$on('$destroy', function () {
                    $window.removeEventListener('message', onChartRequest);
                });
                ensureChart();

                $scope.openInVaidra = function () {
                    if (!$scope.canLaunch || !$scope.patient || !$scope.patient.uuid) return;
                    if (!webBase || !siteId || !apiBase) {
                        $scope.writeStatus = 'error';
                        $scope.writeMessage = 'Missing ' + (!webBase ? 'vaidraWebBaseUrl' : !apiBase ? 'vaidraApiBaseUrl' : 'Bahmni host for site id') + ' in visit config.';
                        return;
                    }
                    var q = new URLSearchParams({
                        source: 'bahmni',
                        site: siteId,
                        patient: $scope.patient.uuid,
                        visit: $scope.visitUuid,
                        ehrOrigin: $window.location.origin
                    });
                    var providerUuid = $rootScope.currentProvider && $rootScope.currentProvider.uuid;
                    if (providerUuid) q.set('provider', providerUuid);
                    ensureChart();
                    $window.open(webBase + '/ehr/launch?' + q.toString(), '_blank');
                };

                var writeCode = readTicket($window, $location);
                if (!writeCode) return;

                $scope.writeStatus = 'saving';
                $scope.writeMessage = 'Saving Consultation Note from Vaidra…';

                var claimed = false;
                var ticketId;
                var tickets = apiBase + '/ehr/bahmni/write-tickets';

                function completeTicket(status, extras) {
                    if (!ticketId) return $q.when();
                    var body = { status: status, code: writeCode };
                    if (extras) {
                        if (extras.vendorResponse) body.vendorResponse = extras.vendorResponse;
                        if (extras.error) body.error = extras.error;
                    }
                    return $http.post(tickets + '/' + encodeURIComponent(ticketId) + '/complete', body);
                }

                $http.post(tickets + '/claim', { code: writeCode }).then(function (res) {
                    claimed = true;
                    var handoff = res.data || {};
                    ticketId = handoff.ticketId;
                    if (!ticketId) return fail('Vaidra write handoff did not return a ticket');
                    if (handoff.patientUuid !== $scope.patient.uuid) {
                        return fail('Vaidra note is for a different patient than this visit');
                    }
                    if (handoff.visitUuid !== $scope.visitUuid) {
                        return fail('Vaidra note is for a different visit');
                    }
                    var names = handoff.noteConceptNames || [NOTE];
                    return $q.all({
                        conceptUuid: resolveConceptUuid(names),
                        encounterUuid: resolveEncounterUuid(handoff.visitUuid, handoff.encounterUuid)
                    }).then(function (ids) {
                        if (!ids.conceptUuid) return fail('Consultation Note concept not found');
                        if (!ids.encounterUuid) return fail('No Consultation encounter on this visit');
                        return $http.post(C.bahmniEncounterUrl, {
                            patientUuid: handoff.patientUuid,
                            visitUuid: handoff.visitUuid,
                            encounterUuid: ids.encounterUuid,
                            locationUuid: handoff.locationUuid,
                            providers: handoff.providerUuid ? [{ uuid: handoff.providerUuid }] : undefined,
                            observations: [{
                                concept: { uuid: ids.conceptUuid, name: names[0] || NOTE },
                                value: handoff.noteText
                            }]
                        });
                    });
                }).then(function (saved) {
                    return completeTicket('completed', { vendorResponse: (saved && saved.data) || {} });
                }).then(function (done) {
                    if (!done || !done.data || done.data.status !== 'completed') {
                        return fail('Vaidra did not accept the OpenMRS save proof');
                    }
                    $scope.writeStatus = 'saved';
                    $scope.writeMessage = 'Consultation Note saved to this visit.';
                    if (!clearTicket($window, $location)) return $state.reload();
                }).catch(function (err) {
                    $scope.writeStatus = 'error';
                    $scope.writeMessage = explainError(err, apiBase, claimed);
                    if (claimed) {
                        completeTicket('failed', { error: $scope.writeMessage }).catch(angular.noop);
                    }
                    if (ticketIsSpent(err, claimed)) {
                        clearTicket($window, $location);
                    }
                });
            }

            return {
                restrict: 'E',
                link: link,
                scope: {
                    patient: '=',
                    visitUuid: '=',
                    visitSummary: '=',
                    config: '='
                },
                template: '<ng-include src="contentUrl"/>'
            };
        }]);
