import React from "react";

/**
 * Returns true if `obj` has at least one value that is considered non-empty.
 * A value is "empty" when it is null, undefined, an empty string '', an empty
 * array [], or an empty plain object {}.
 * Used in form components to guard against dispatching a blank initial-mount
 * emission from FormComposer, which would overwrite already-populated Redux state.
 */
export const hasAnyNonEmptyValue = (obj) => {
  if (obj === null || obj === undefined || typeof obj !== "object") return false;
  return Object.values(obj).some((v) => {
    if (v === null || v === undefined || v === "") return false;
    if (Array.isArray(v)) return v.length > 0;
    if (typeof v === "object" && v !== null) return Object.keys(v).length > 0;
    return true;
  });
};

/* methid to get date from epoch */
export const convertEpochToDate = (dateEpoch) => {
    // Returning null in else case because new Date(null) returns initial date from calender
    if (dateEpoch) {
        const dateFromApi = new Date(dateEpoch);
        let month = dateFromApi.getMonth() + 1;
        let day = dateFromApi.getDate();
        let year = dateFromApi.getFullYear();
        month = (month > 9 ? "" : "0") + month;
        day = (day > 9 ? "" : "0") + day;
        return `${day}/${month}/${year}`;
    } else {
        return null;
    }
};

export const stringReplaceAll = (str = "", searcher = "", replaceWith = "") => {
    if (searcher == "") return str;
    while (str.includes(searcher)) {
      str = str.replace(searcher, replaceWith);
    }
    return str;
  };

export const businessServiceList = (isCode= false) => {
    let isSearchScreen = window.location.href.includes("/search");
    const availableBusinessServices = [{
        code: isSearchScreen ? "FIRE_NOC" : "FIRE_NOC_SRV",
        active: true,
        roles: ["FIRE_NOC_APPROVER"],
        i18nKey: "WF_FIRE_NOC_FIRE_NOC_SRV",
    }, {
        code: isSearchScreen ? "AIRPORT_AUTHORITY" : "AIRPORT_NOC_SRV",
        active: true,
        roles: ["AIRPORT_AUTHORITY_APPROVER"],
        i18nKey: "WF_FIRE_NOC_AIRPORT_NOC_SRV"
    }];

    const newAvailableBusinessServices = [];
    const loggedInUserRoles = Digit.UserService.getUser().info.roles;
    availableBusinessServices.map(({ roles }, index) => {
        roles.map((role) => {
            loggedInUserRoles.map((el) => {
                if (el.code === role) {
                    isCode ? newAvailableBusinessServices.push(availableBusinessServices?.[index]?.code) : newAvailableBusinessServices.push(availableBusinessServices?.[index])
                }
            })
        })
    });

    return newAvailableBusinessServices;
}

export const pdfDownloadLink = (documents = {}, fileStoreId = "", format = "") => {
    /* Need to enhance this util to return required format*/
  
    let downloadLink = documents[fileStoreId] || "";
    let differentFormats = downloadLink?.split(",") || [];
    let fileURL = "";
    differentFormats.length > 0 &&
      differentFormats.map((link) => {
        if (!link.includes("large") && !link.includes("medium") && !link.includes("small")) {
          fileURL = link;
        }
      });
    return fileURL;
  };

  export const pdfDocumentName = (documentLink = "", index = 0) => {
    let documentName = decodeURIComponent(documentLink.split("?")[0].split("/").pop().slice(13)) || `Document - ${index + 1}`;
    return documentName;
  };

  export const EmployeeData = (tenantId, approver) => {
  const employeeDataByCode = Digit.Hooks.useEmployeeSearch(tenantId, { codes: approver, isActive: true }, { enabled: !!approver });
  const employeeDataByName = Digit.Hooks.useEmployeeSearch( tenantId, { names: approver, isActive: true }, { enabled: !!approver && !employeeDataByCode?.data?.Employees?.length } );
  const employeeData = employeeDataByCode?.data?.Employees?.length ? employeeDataByCode : employeeDataByName;
  const officerRaw = employeeData?.data?.Employees?.[0];
  const officerAssignment = officerRaw?.assignments?.[0];

  const officer = officerRaw
    ? {
        code: officerRaw?.code,
        id: officerRaw?.id,
        name: officerRaw?.user?.name,
        department: officerAssignment?.department,
        designation: officerAssignment?.designation,
      }
    : null;

  return { officer };
};