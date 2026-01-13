import { PrivateRoute, BreadCrumb, AppContainer, BackButton } from "@upyog/digit-ui-react-components";
import React, { useState, useEffect } from "react";
import { useTranslation } from "react-i18next";
import { Switch, useLocation } from "react-router-dom";
import { ESTLinks } from "../../Module";
import SearchApp from "./SearchApp";
import ManageProperties from "../../components/ManageProperties";
import ESTPropertyAllotteeDetails from "../../PageComponents/ESTPropertyAllotteeDetails"; 
import ESTRegCreate from "./Create";
import ESTAssignAssetCreate from "./Create/AssignAssetIndex";
import AllProperties  from "../../components/AllProperties";
import ESTInbox from "./Inbox";
import ESTManageProperties from "../../PageComponents/ESTManageProperties";
import ESTActions from "../../PageComponents/ESTActions";
import ManageRebate from "../../components/ManageRebate";
import ManageInterest from "../../components/ManageInterest";
import ManagePenalty from "../../components/ManagePenalty";


const EmployeeApp = ({ path, url, userType }) => {
  const { t } = useTranslation();
  const location = useLocation();
  const [isMobile, setIsMobile] = useState(window.innerWidth <= 768);
  const ESTApplicationDetails = Digit?.ComponentRegistryService?.getComponent("ESTApplicationDetails");

  useEffect(() => {
    const handleResize = () => setIsMobile(window.innerWidth <= 768);
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  const inboxInitialState = {
    pageOffset: 0,
    pageSize: 10,
    sortParams: [{ id: "createdTime", desc: true }],
    searchParams: {}
  };


  const ESTBreadCrumbs = ({ location }) => {
    const { t } = useTranslation();
    
    const crumbs = [
      {
        path: "/upyog-ui/employee",
        content: t("ES_COMMON_HOME"),
        show: true,
      },
      {
        path: "/upyog-ui/employee/est/inbox",
        content: t("INBOX"),
        show: location.pathname.includes("est/inbox"),
      },
      {
        path: "/upyog-ui/employee/est/search-applications",
        content: t("ES_COMMON_APPLICATION_SEARCH"),
        show: location.pathname.includes("est/search-applications"),
      },
      {
        path: "/upyog-ui/employee/est/create-asset",
        content: t("EST_CREATE_ASSET"),
        show: location.pathname.includes("est/create-asset"),
      },
      {
        path: "/upyog-ui/employee/est/manage-properties-table",
        content: t("EST_MANAGE_PROPERTY"),
        show: location.pathname.includes("est/manage-properties-table"),
      },
      {
        path: "/upyog-ui/employee/est/actions",
        content: t("EST_ACTION"),
        show: location.pathname.includes("est/actions"),
      },
      {
        path: "/upyog-ui/employee/est/manage-rebate",
        content: t("EST_MANAGE_REBATE"),
        show: location.pathname.includes("est/manage-rebate"),
      },
      {
        path: "/upyog-ui/employee/est/manage-interest",
        content: t("EST_MANAGE_INTEREST"),
        show: location.pathname.includes("est/manage-interest"),
      },
      {
        path: "/upyog-ui/employee/est/manage-penalty",
        content: t("EST_MANAGE_PENALTY"),
        show: location.pathname.includes("est/manage-penalty"),
      },
    ];

    return (
      <BreadCrumb
        style={isMobile ? { 
          display: "flex", 
          fontSize: "12px", 
          padding: "5px" 
        } : { 
          margin: "0 0 4px", 
          color: "#000000" 
        }}
        spanStyle={{ maxWidth: "min-content" }}
        crumbs={crumbs}
      />
    );
  };
  
  
  return (
    <Switch>
      <AppContainer>
        <React.Fragment>
          <div className="ground-container" style={{ padding: isMobile ? '10px' : '20px' }}>
            <div style={{ 
              marginLeft: isMobile ? "0" : "-4px", 
              display: "flex", 
              alignItems: "center" 
            }}>
              <ESTBreadCrumbs location={location} />
            </div>

            <PrivateRoute exact path={`${path}/`} component={() => <ESTLinks matchPath={path} userType={userType} />} />
            <PrivateRoute path={`${path}/property-allottee-details`} component={(props) => <ESTPropertyAllotteeDetails {...props} t={t} parentRoute={path} />} />
            <PrivateRoute path={`${path}/assignassets`} component={(props) => <ESTAssignAssetCreate {...props} parentRoute={path} />} />
            <PrivateRoute path={`${path}/inbox`} component={() => (
              <ESTInbox
                parentRoute={path}
                businessService="EST"
                initialStates={inboxInitialState}
                isInbox={true}
                filterComponent="EST_INBOX_FILTER"
                useNewInboxAPI={true}
              />
            )} />
            <PrivateRoute path={`${path}/search-applications`} component={(props) => <SearchApp {...props} parentRoute={path} />} />
            <PrivateRoute path={`${path}/create-asset`} component={(props) => <ESTRegCreate {...props} parentRoute={path} />} />
            <PrivateRoute path={`${path}/manage-properties`} component={(props) => <ESTManageProperties {...props} parentRoute={path} />} />
            <PrivateRoute path={`${path}/all-properties`} component={(props) => <AllProperties {...props}  t={t}  parentRoute={path} />} />
            <PrivateRoute path={`${path}/manage-properties-table`} component={(props) => <ManageProperties {...props} t={t} parentRoute={path} />} />
            <PrivateRoute path={`${path}/application-details/:assetNo`} component={() => <ESTApplicationDetails />} />
           <PrivateRoute
              path={`${path}/actions`}
              component={ESTActions}
            />
            <PrivateRoute path={`${path}/manage-rebate`} component={(props) => <ManageRebate {...props} t={t} />} />
            <PrivateRoute path={`${path}/manage-interest`} component={(props) => <ManageInterest {...props} t={t} />} />
            <PrivateRoute path={`${path}/manage-penalty`} component={(props) => <ManagePenalty {...props} t={t} />} />


          </div>
        </React.Fragment>
      </AppContainer>
    </Switch>
  );
};

export default EmployeeApp;
