// React core imports
import React ,{Children, Fragment}from "react";
// Translation hook
import { useTranslation } from "react-i18next";
import { useQueryClient } from "react-query";
// React Router utilities
import { Redirect, Route, Switch, useHistory, useLocation, useRouteMatch } from "react-router-dom";
import { Config } from "../../../config/Create/config";


/**
 * ESTRegCreate
 * -------------
 * Main container component responsible for:
 * - Rendering multi-step EST registration form
 * - Handling navigation between steps
 * - Managing form data in session storage
 * - Rendering check & acknowledgement screens
 */
const ESTRegCreate = ({ parentRoute }) => {

  const queryClient = useQueryClient();
  const match = useRouteMatch();
  const { t } = useTranslation();
  const { pathname } = useLocation();
  const history = useHistory();
  const stateId = Digit.ULBService.getStateId();
  let config = [];
  const [params, setParams, clearParams] = Digit.Hooks.useSessionStorage("EST_NEW_REGISTRATION_CREATES", {});

   /**
   * goNext
   * -------
   * Handles navigation logic between form steps.
   * Supports:
   * - Skipping steps
   * - Multiple-entry screens (owners, units, etc.)
   * - Backward and forward navigation
   */

  const goNext = (skipStep, index, isAddMultiple, key) => {  
    let currentPath = pathname.split("/").pop(),
      lastchar = currentPath.charAt(currentPath.length - 1),
      isMultiple = false,
      nextPage;
    if (Number(parseInt(currentPath)) || currentPath == "0" || currentPath == "-1") {
      if (currentPath == "-1" || currentPath == "-2") {
        currentPath = pathname.slice(0, -3);
        currentPath = currentPath.split("/").pop();
        isMultiple = true;
      } else {
        currentPath = pathname.slice(0, -2);
        currentPath = currentPath.split("/").pop();
        isMultiple = true;
      }
    } else {
      isMultiple = false;
    }
    if (!isNaN(lastchar)) {
      isMultiple = true;
    }
    let { nextStep = {} } = config.find((routeObj) => routeObj.route === currentPath);


    let redirectWithHistory = history.push;
    if (skipStep) {
      redirectWithHistory = history.replace;
    }
    if (isAddMultiple) {
      nextStep = key;
    }
    if (nextStep === null) {
      return redirectWithHistory(`${match.path}/check`);
    }
    if (!isNaN(nextStep.split("/").pop())) {
      nextPage = `${match.path}/${nextStep}`;
    }
     else {
      nextPage = isMultiple && nextStep !== "map" ? `${match.path}/${nextStep}/${index}` : `${match.path}/${nextStep}`;
    }

    redirectWithHistory(nextPage);
  };

   /**
   * Clear old form data when user enters the first screen again,
   * unless user navigated using browser back button
   */
  // to clear formdata if the data is present before coming to first page of form
  if(params && Object.keys(params).length>0 && window.location.href.includes("/info") && sessionStorage.getItem("docReqScreenByBack") !== "true")
    {
      clearParams();
      queryClient.invalidateQueries("EST_NEW_REGISTRATION_CREATES");
    }

  const estcreate = async () => {
  history.replace(`${match.path}/acknowledgement`);
};

  /**
   * handleSelect
   * ------------
   * Saves form data into session storage
   * Handles special cases like owners and units (multiple entries)
   */

  function handleSelect(key, data, skipStep, index, isAddMultiple = false) {
  
  // if (key === "owners") {
  //   let owners = params.owners || [];
  //   owners[index] = data;
  //   setParams({ ...params, ...{ [key]: [...owners] } });
  // } else if (key === "units") {
  //   let units = params.units || [];
  //   units = data;
  //   setParams({ ...params, units });
  // } else {

  // }
  setParams({ ...params, [key]: data });
  goNext(skipStep, index, isAddMultiple, key);
}
  const handleSkip = () => {};
  const handleMultiple = () => {};


 /**
   * onSuccess
   * ----------
   * Called after successful submission
   * Clears session storage and invalidates cached queries
   */
  const onSuccess = () => {
    clearParams();
    queryClient.invalidateQueries("EST_NEW_REGISTRATION_CREATES");

  };
  
  let commonFields = Config;
  commonFields.forEach((obj) => {
    config = config.concat(obj.body.filter((a) => !a.hideInCitizen));
  });
  
  config.indexRoute = "newRegistration";

  const ESTRegCheckPage = Digit?.ComponentRegistryService?.getComponent("ESTRegCheckPage");
  const ESTAcknowledgement = Digit?.ComponentRegistryService?.getComponent("ESTAcknowledgement");
  
  return (
    <Switch>
      {config.map((routeObj, index) => {
        const { component, texts, inputs, key } = routeObj;
        const Component = typeof component === "string" ? Digit.ComponentRegistryService.getComponent(component) : component;
        const user = Digit.UserService.getUser().info.type;
        return (
  <Route path={`${match.path}/${routeObj.route}`} key={index}>
  <Component 
    config={routeObj} 
    onSelect={handleSelect} 
    onSkip={handleSkip} 
    t={t} 
    formData={params} 
    onAdd={handleMultiple} 
    userType={user}
    parentRoute={match.path}
  />
</Route>
)
      })}

      <Route path={`${match.path}/check`}>
        <ESTRegCheckPage onSubmit={estcreate} value={params} />
      </Route>
      <Route path={`${match.path}/acknowledgement`}>
        <ESTAcknowledgement data={params} onSuccess={onSuccess}/>
      </Route>
      <Route>
        <Redirect to={`${match.path}/${config.indexRoute}`} />  
      </Route>
    </Switch>
  );
};

export default ESTRegCreate;