import React, { useEffect, useState } from "react";
import { FormStep, CardLabel } from "@nudmcdgnpm/digit-ui-react-components";
import Timeline from "../components/PTRTimeline";
import Mics from "../components/Mic";
import TextInput from "../components/TextInput"; // made new as there was no onFocus  component
import MobileNumber from "../components/mobileNumber"; // made new as there was no onFocus  component

const PTRCitizenDetails = ({ t, config, onSelect, userType, formData, renewApplication }) => {
  const user = Digit.UserService.getUser().info; // Service to fetch user information
  const inputStyles = { width: user.type === "EMPLOYEE" ? "50%" : "86%" };
  let validation = {};

  const [response, setResponse] = useState(""); // State to store the response
  const [key, setkey] = useState(0); // State to manage a key, possibly for re-rendering or unique identification
  const [enablemic, setenablemic] = useState(false); // State to enable or disable the microphone
  const [activeMicId, setActiveMicId] = useState(null); // State to track the active microphone ID
  const [applicantName, setName] = useState(
    renewApplication?.applicantName || (user.type === "EMPLOYEE" ? "" : user?.name) || formData?.ownerss?.applicantName || ""
  );
  const [emailId, setEmail] = useState(renewApplication?.emailId || formData?.ownerss?.emailId || "");
  const [mobileNumber, setMobileNumber] = useState(
    renewApplication?.mobileNumber || (user.type === "EMPLOYEE" ? "" : user?.mobileNumber) || formData?.ownerss?.mobileNumber || ""
  );
  const [alternateNumber, setAltMobileNumber] = useState(formData?.ownerss?.alternateNumber || "");
  const [fatherName, setFatherOrHusbandName] = useState(renewApplication?.fatherName || formData?.ownerss?.fatherName || "");

  // Automatically set input values from response
  useEffect(() => {
    if (response) {
      // Switch case to handle different microphone inputs based on the active mic ID
      switch (key) {
        case "mic1":
          setName(response); // Set the name based on the response
          break;
        case "mic2":
          setMobileNumber(response.replace(/ /g, ""));
          break;
        case "mic3":
          setAltMobileNumber(response.replace(/ /g, ""));
          break;
        case "mic4":
          setFatherOrHusbandName(response);
          break;
        case "mic5":
          setEmail(response);
          break;
        default:
          break;
      }
    }
  }, [response]);

  const goNext = () => {
    setenablemic(false); // Disable mic
    setActiveMicId(null); // Clear active mic ID

    let owner = formData.ownerss;
    let ownerStep;
    if (userType === "citizen") {
      ownerStep = { ...owner, applicantName, mobileNumber, alternateNumber, fatherName, emailId };
      onSelect(config.key, { ...formData[config.key], ...ownerStep }, false);
    } else {
      ownerStep = { ...owner, applicantName, mobileNumber, alternateNumber, fatherName, emailId };
      onSelect(config.key, ownerStep, false);
    }
  };

  const onSkip = () => onSelect();

  useEffect(() => {
    if (userType === "citizen") {
      goNext();
    }
  }, [applicantName, mobileNumber, fatherName, emailId]);

  return (
    <React.Fragment>
      {<Timeline currentStep={1} />}

      <FormStep config={config} onSelect={goNext} onSkip={onSkip} t={t} isDisabled={!applicantName || !mobileNumber || !fatherName || !emailId}>
        {/* <CardLabel>
          {`${t("PTR_APPLICANT_NAME")}`} <span className="astericColor">*</span>
        </CardLabel>
        <div style={{ display: "flex", flexDirection: "row" }}>
          <TextInput
            t={t}
            onFocus={() => {
              setenablemic(true); // Enable the microphone when the input field is focused
              setActiveMicId("mic1"); // Set the active microphone ID to "mic1"
            }}
            onBlur={() => {
              setenablemic(false); // Disable the microphone when the input field loses focus
              setActiveMicId(null); // Clear the active microphone ID
            }}
            type={"text"}
            isMandatory={false}
            optionKey="i18nKey"
            name="applicantName"
            value={applicantName}
            style={inputStyles}
            onChange={(e) => setName(e.target.value)} // Update the name state when the input value changes
            ValidationRequired={true}
            {...(validation = {
              isRequired: true,
              pattern: "^[a-zA-Z ]+$",
              type: "tel",
              title: t("PT_NAME_ERROR_MESSAGE"),
            })}
          />
          <div style={{ display: "flex", marginTop: "10px" }}>
            <Mics
              setResponse={setResponse} // Function to set the response state
              id={"mic1"} // Unique identifier for this microphone instance
              setkey={setkey} // Function to set the key state
              enablemic={enablemic && activeMicId === "mic1"} // Enable the microphone if enablemic is true and activeMicId is "mic1"
            />
          </div>
        </div> */}

        <CardLabel>
          {`${t("PTR_MOBILE_NUMBER")}`} <span className="astericColor">*</span>
        </CardLabel>
        <div style={{ display: "block", width: "100%" }}>
          <MobileNumber
            value={mobileNumber}
            onFocus={() => {
              setenablemic(true);
              setActiveMicId("mic2");
            }}
            onBlur={() => {
              setenablemic(false);
              setActiveMicId(null);
            }}
            name="mobileNumber"
            onChange={(e) => setMobileNumber(e?.target?.value || e)} // Update the mobile number state when the input value changes, handling both event and direct value scenarios
            style={{ width: "85%" }}
            {...{ required: true, type: "tel", title: t("CORE_COMMON_APPLICANT_MOBILE_NUMBER_INVALID") }}
          />
          <div style={{ marginLeft: "58%", position: "relative", top: "-42px" }}>
            <Mics
              setResponse={setResponse} // Function to set the response state
              id="mic2" // Unique identifier for this microphone instance
              setkey={setkey} // Function to set the key state
              enablemic={enablemic && activeMicId === "mic2"} // Enable the microphone if enablemic is true and activeMicId is "mic2"
            />
          </div>
        </div>

        <CardLabel>{`${t("PTR_ALT_MOBILE_NUMBER")}`}</CardLabel>
        <div style={{ display: "block", width: "100%" }}>
          <MobileNumber
            value={alternateNumber}
            onFocus={() => {
              setenablemic(true);
              setActiveMicId("mic3");
            }}
            onBlur={() => {
              setenablemic(false);
              setActiveMicId(null);
            }}
            name="alternateNumber"
            onChange={(e) => setAltMobileNumber(e?.target?.value || e)}
            style={{ width: "85%" }}
            {...{ required: false, type: "tel", title: t("CORE_COMMON_APPLICANT_MOBILE_NUMBER_INVALID") }}
          />
          <div style={{ marginLeft: "58%", position: "relative", top: "-42px" }}>
            <Mics
              setResponse={setResponse} // Function to set the response state
              id="mic3" // Unique identifier for this microphone instance
              setkey={setkey} // Function to set the key state
              enablemic={enablemic && activeMicId === "mic3"} // Enable the microphone if enablemic is true and activeMicId is "mic3"
            />
          </div>
        </div>

        <CardLabel>
          {`${t("PTR_FATHER_HUSBAND_NAME")}`} <span className="astericColor">*</span>
        </CardLabel>
        <div style={{ display: "flex", flexDirection: "row" }}>
          <TextInput
            t={t}
            type={"text"}
            isMandatory={false}
            onFocus={() => {
              setenablemic(true);
              setActiveMicId("mic4");
            }}
            onBlur={() => {
              setenablemic(false);
              setActiveMicId(null);
            }}
            optionKey="i18nKey"
            name="fatherName"
            style={inputStyles}
            value={fatherName}
            onChange={(e) => setFatherOrHusbandName(e.target.value)} // Update the father or husband's name state when the input value changes
            ValidationRequired={true}
            {...(validation = {
              isRequired: true,
              pattern: "^[a-zA-Z ]+$",
              type: "tel",
              title: t("PT_NAME_ERROR_MESSAGE"),
            })}
          />
          <div style={{ display: "flex", marginTop: "10px" }}>
            <Mics
              setResponse={setResponse} // Function to set the response state
              id="mic4" // Unique identifier for this microphone instance
              setkey={setkey} // Function to set the key state
              enablemic={enablemic && activeMicId === "mic4"} // Enable the microphone if enablemic is true and activeMicId is "mic4"
            />
          </div>
        </div>

        <CardLabel>
          {`${t("PTR_EMAIL_ID")}`} <span className="astericColor">*</span>
        </CardLabel>
        <div style={{ display: "flex", flexDirection: "row" }}>
          <TextInput
            t={t}
            type={"email"}
            onFocus={() => {
              setenablemic(true);
              setActiveMicId("mic5");
            }}
            onBlur={() => {
              setenablemic(false);
              setActiveMicId(null);
            }}
            isMandatory={true}
            optionKey="i18nKey"
            name="emailId"
            value={emailId}
            style={inputStyles}
            onChange={(e) => setEmail(e.target.value)}
            ValidationRequired={true}
            {...(validation = {
              isRequired: true,
              pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z]+\\.[a-zA-Z]{3,4}$",
              type: "email",
              title: t("PT_NAME_ERROR_MESSAGE"),
            })}
          />
          <div style={{ display: "flex", marginTop: "10px" }}>
            <Mics
              setResponse={setResponse} // Function to set the response state
              id="mic5" // Unique identifier for this microphone instance
              setkey={setkey} // Function to set the key state
              enablemic={enablemic && activeMicId === "mic5"} // Enable the microphone if enablemic is true and activeMicId is "mic5"
            />{" "}
          </div>
        </div>
      </FormStep>
    </React.Fragment>
  );
};

export default PTRCitizenDetails;

// this is the best code for now
// import React, { useEffect, useState } from "react";
// import { FormStep, CardLabel } from "@nudmcdgnpm/digit-ui-react-components";
// import Timeline from "../components/PTRTimeline";
// import Mics from "../components/Mic";
// import TextInput from "../components/TextInput";
// import MobileNumber from "../components/mobineNumber";

// const PTRCitizenDetails = ({ t, config, onSelect, userType, formData, renewApplication }) => {
//   const user = Digit.UserService.getUser().info; // Service to fetch user information
//   const inputStyles = { width: user.type === "EMPLOYEE" ? "50%" : "86%" };
//   let validation = {};

//   const [response, setResponse] = useState("");
//   const [key, setkey] = useState(0);
//   const [enablemic, setenablemic] = useState(false);
//   const [activeMicId, setActiveMicId] = useState(null); // Track active mic ID
//   const [applicantName, setName] = useState(
//     renewApplication?.applicantName || (user.type === "EMPLOYEE" ? "" : user?.name) || formData?.ownerss?.applicantName || ""
//   );
//   const [emailId, setEmail] = useState(renewApplication?.emailId || formData?.ownerss?.emailId || "");
//   const [mobileNumber, setMobileNumber] = useState(
//     renewApplication?.mobileNumber || (user.type === "EMPLOYEE" ? "" : user?.mobileNumber) || formData?.ownerss?.mobileNumber || ""
//   );
//   const [alternateNumber, setAltMobileNumber] = useState(formData?.ownerss?.alternateNumber || "");
//   const [fatherName, setFatherOrHusbandName] = useState(renewApplication?.fatherName || formData?.ownerss?.fatherName || "");

//   // Automatically set input values from response
//   useEffect(() => {
//     if (response) {
//       switch (key) {
//         case "mic1":
//           setName(response);
//           break;
//         case "mic2":
//           setMobileNumber(response.replace(/ /g, ""));
//           break;
//         case "mic3":
//           setAltMobileNumber(response.replace(/ /g, ""));
//           break;
//         case "mic4":
//           setFatherOrHusbandName(response);
//           break;
//         case "mic5":
//           setEmail(response);
//           break;
//         default:
//           break;
//       }
//     }
//   }, [response]);

//   const goNext = () => {
//     setenablemic(false); // Disable mic
//     setActiveMicId(null); // Clear active mic ID

//     let owner = formData.ownerss;
//     let ownerStep;
//     if (userType === "citizen") {
//       ownerStep = { ...owner, applicantName, mobileNumber, alternateNumber, fatherName, emailId };
//       onSelect(config.key, { ...formData[config.key], ...ownerStep }, false);
//     } else {
//       ownerStep = { ...owner, applicantName, mobileNumber, alternateNumber, fatherName, emailId };
//       onSelect(config.key, ownerStep, false);
//     }
//   };

//   const onSkip = () => onSelect();

//   useEffect(() => {
//     if (userType === "citizen") {
//       goNext();
//     }
//   }, [applicantName, mobileNumber, fatherName, emailId]);

//   return (
//     <React.Fragment>
//       {<Timeline currentStep={1} />}

//       <FormStep config={config} onSelect={goNext} onSkip={onSkip} t={t} isDisabled={!applicantName || !mobileNumber || !fatherName || !emailId}>
//         {/* Applicant Name */}
//         <CardLabel>
//           {`${t("PTR_APPLICANT_NAME")}`} <span className="astericColor">*</span>
//         </CardLabel>
//         <div style={{ display: "flex", flexDirection: "row" }}>
//           <TextInput
//             t={t}
//             onFocus={() => {
//               setenablemic(true);
//               setActiveMicId("mic1");
//             }}
//             onBlur={() => {
//               setenablemic(false);
//               setActiveMicId(null);
//             }}
//             type={"text"}
//             isMandatory={false}
//             optionKey="i18nKey"
//             name="applicantName"
//             value={applicantName}
//             style={inputStyles}
//             onChange={(e) => setName(e.target.value)}
//             ValidationRequired={true}
//             {...(validation = {
//               isRequired: true,
//               pattern: "^[a-zA-Z ]+$",
//               type: "tel",
//               title: t("PT_NAME_ERROR_MESSAGE"),
//             })}
//           />
//           <div style={{ display: "flex", marginTop: "10px" }}>
//             <Mics setResponse={setResponse} id={"mic1"} setkey={setkey} enablemic={enablemic && activeMicId === "mic1"} />
//           </div>
//         </div>

//         <CardLabel>
//           {`${t("PTR_MOBILE_NUMBER")}`} <span className="astericColor">*</span>
//         </CardLabel>
//         <div style={{ display: "block" }}>
//           <MobileNumber
//             value={mobileNumber}
//             onFocus={() => {
//               setenablemic(true);
//               setActiveMicId("mic2");
//             }}
//             onBlur={() => {
//               setenablemic(false);
//               setActiveMicId(null);
//             }}
//             name="mobileNumber"
//             onChange={(e) => setMobileNumber(e?.target?.value || e)}
//             style={{ inputStyles }}
//             {...{ required: true, type: "tel", title: t("CORE_COMMON_APPLICANT_MOBILE_NUMBER_INVALID") }}
//           />
//           <div style={{ marginLeft: "10px", marginTop: "10px" }}>
//             <Mics setResponse={setResponse} id="mic2" setkey={setkey} enablemic={enablemic && activeMicId === "mic2"} />
//           </div>
//         </div>

//         <CardLabel>{`${t("PTR_ALT_MOBILE_NUMBER")}`}</CardLabel>
//         <div style={{ display: "flex", flexDirection: "row" }}>
//           <MobileNumber
//             value={alternateNumber}
//             onFocus={() => {
//               setenablemic(true);
//               setActiveMicId("mic3");
//             }}
//             onBlur={() => {
//               setenablemic(false);
//               setActiveMicId(null);
//             }}
//             name="alternateNumber"
//             onChange={(e) => setAltMobileNumber(e?.target?.value || e)}
//             style={inputStyles}
//             {...{ required: false, type: "tel", title: t("CORE_COMMON_APPLICANT_MOBILE_NUMBER_INVALID") }}
//           />
//           <div style={{ display: "flex", marginTop: "10px" }}>
//             <Mics setResponse={setResponse} id="mic3" setkey={setkey} enablemic={enablemic && activeMicId === "mic3"} />
//           </div>
//         </div>

//         {/* Father/Husband Name */}
//         <CardLabel>
//           {`${t("PTR_FATHER_HUSBAND_NAME")}`} <span className="astericColor">*</span>
//         </CardLabel>
//         <div style={{ display: "flex", flexDirection: "row" }}>
//           <TextInput
//             t={t}
//             type={"text"}
//             isMandatory={false}
//             onFocus={() => {
//               setenablemic(true);
//               setActiveMicId("mic4");
//             }}
//             onBlur={() => {
//               setenablemic(false);
//               setActiveMicId(null);
//             }}
//             optionKey="i18nKey"
//             name="fatherName"
//             style={inputStyles}
//             value={fatherName}
//             onChange={(e) => setFatherOrHusbandName(e.target.value)}
//             ValidationRequired={true}
//             {...(validation = {
//               isRequired: true,
//               pattern: "^[a-zA-Z ]+$",
//               type: "tel",
//               title: t("PT_NAME_ERROR_MESSAGE"),
//             })}
//           />
//           <div style={{ display: "flex", marginTop: "10px" }}>
//             <Mics setResponse={setResponse} id="mic4" setkey={setkey} enablemic={enablemic && activeMicId === "mic4"} />
//           </div>
//         </div>

//         {/* Email ID */}
//         <CardLabel>
//           {`${t("PTR_EMAIL_ID")}`} <span className="astericColor">*</span>
//         </CardLabel>
//         <div style={{ display: "flex", flexDirection: "row" }}>
//           <TextInput
//             t={t}
//             type={"email"}
//             onFocus={() => {
//               setenablemic(true);
//               setActiveMicId("mic5");
//             }}
//             onBlur={() => {
//               setenablemic(false);
//               setActiveMicId(null);
//             }}
//             isMandatory={true}
//             optionKey="i18nKey"
//             name="emailId"
//             value={emailId}
//             style={inputStyles}
//             onChange={(e) => setEmail(e.target.value)}
//             ValidationRequired={true}
//             {...(validation = {
//               isRequired: true,
//               pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z]+\\.[a-zA-Z]{3,4}$",
//               type: "email",
//               title: t("PT_NAME_ERROR_MESSAGE"),
//             })}
//           />
//           <div style={{ display: "flex", marginTop: "10px" }}>
//             <Mics setResponse={setResponse} id="mic5" setkey={setkey} enablemic={enablemic && activeMicId === "mic5"} />
//           </div>
//         </div>
//       </FormStep>
//     </React.Fragment>
//   );
// };

// export default PTRCitizenDetails;

// import React, { useEffect, useState } from "react";
// import { FormStep, CardLabel, MobileNumber } from "@nudmcdgnpm/digit-ui-react-components";
// import Timeline from "../components/PTRTimeline";
// import Mics from "../components/Mic";
// import TextInput from "../components/TextInput";

// const PTRCitizenDetails = ({ t, config, onSelect, userType, formData, renewApplication }) => {
//   const user = Digit.UserService.getUser().info; // service to fetch user information
//   const inputStyles = { width: user.type === "EMPLOYEE" ? "50%" : "86%" };
//   let validation = {};

//   const [response, setResponse] = useState("");
//   const [key, setkey] = useState(0);
//   const [enablemic, setenablemic] = useState(false);
//   const [applicantName, setName] = useState(
//     renewApplication?.applicantName || (user.type === "EMPLOYEE" ? "" : user?.name) || formData?.ownerss?.applicantName || ""
//   );
//   const [emailId, setEmail] = useState(renewApplication?.emailId || formData?.ownerss?.emailId || "");
//   const [mobileNumber, setMobileNumber] = useState(
//     renewApplication?.mobileNumber || (user.type === "EMPLOYEE" ? "" : user?.mobileNumber) || formData?.ownerss?.mobileNumber || ""
//   );
//   const [alternateNumber, setAltMobileNumber] = useState(formData?.ownerss?.alternateNumber || "");
//   const [fatherName, setFatherOrHusbandName] = useState(renewApplication?.fatherName || formData?.ownerss?.fatherName || "");
//   console.log("idkey", key);
//   console.log("response", response);

//   function setOwnerName(e) {
//     setName(e.target.value);
//   }

//   function setOwnerEmail(e) {
//     setEmail(e.target.value);
//   }

//   function setMobileNo(e) {
//     // If `e` is a value (not an event), set it directly
//     setMobileNumber(e?.target?.value || e);
//   }

//   function setAltMobileNo(e) {
//     setAltMobileNumber(e?.target?.value || e);
//   }

//   // Automatically set father's name from response if available
//   useEffect(() => {
//     if (response) {
//       switch (key) {
//         case "mic1":
//           setName(response);
//           break;

//         case "mic2":
//           setMobileNo(response.replace(/ /g, ""));
//           break;
//         case "mic3":
//           setAltMobileNo(response.replace(/ /g, ""));
//           break;
//         case "mic4":
//           setFatherOrHusbandName(response);
//           break;
//         case "mic5":
//           setEmail(response);
//           break;

//         default:
//           break;
//       }
//     }
//   }, [response]); // Update whenever response changes

//   const goNext = () => {
//     let owner = formData.ownerss;
//     let ownerStep;
//     if (userType === "citizen") {
//       ownerStep = { ...owner, applicantName, mobileNumber, alternateNumber, fatherName, emailId };
//       onSelect(config.key, { ...formData[config.key], ...ownerStep }, false);
//     } else {
//       ownerStep = { ...owner, applicantName, mobileNumber, alternateNumber, fatherName, emailId };
//       onSelect(config.key, ownerStep, false);
//     }
//   };

//   const onSkip = () => onSelect();

//   useEffect(() => {
//     if (userType === "citizen") {
//       goNext();
//     }
//   }, [applicantName, mobileNumber, fatherName, emailId]);

//   console.log("key sidjfolsdjf ::: ", key);

//   return (
//     <React.Fragment>
//       {<Timeline currentStep={1} />}

//       <FormStep config={config} onSelect={goNext} onSkip={onSkip} t={t} isDisabled={!applicantName || !mobileNumber || !fatherName || !emailId}>
//         <CardLabel>
//           {`${t("PTR_APPLICANT_NAME")}`} <span className="astericColor">*</span>
//         </CardLabel>
//         <div style={{ display: "flex", flexDirection: "row" }}>
//           <TextInput
//             t={t}
//             onFocus={() => setenablemic(true)}
//             onBlur={() => setenablemic(false)}
//             type={"text"}
//             isMandatory={false}
//             optionKey="i18nKey"
//             name="applicantName"
//             value={applicantName}
//             style={inputStyles}
//             onChange={setOwnerName}
//             ValidationRequired={true}
//             {...(validation = {
//               isRequired: true,
//               pattern: "^[a-zA-Z ]+$",
//               type: "tel",
//               title: t("PT_NAME_ERROR_MESSAGE"),
//             })}
//           />
//           <div style={{ display: "flex", marginTop: "10px" }}>
//             <Mics setResponse={setResponse} id={"mic1"} setkey={setkey} enablemic={enablemic}/>
//           </div>
//         </div>

//         <CardLabel>
//           {`${t("PTR_MOBILE_NUMBER")}`} <span className="astericColor">*</span>
//         </CardLabel>
//         <div style={{ display: "block" }}>
//           <MobileNumber
//             value={mobileNumber}
//             onFocus={() => setenablemic(true)}
//             onBlur={() => setenablemic(false)}
//             name="mobileNumber"
//             onChange={setMobileNo}
//             style={{ inputStyles }}
//             {...{ required: true, type: "tel", title: t("CORE_COMMON_APPLICANT_MOBILE_NUMBER_INVALID") }}
//           />
//           <div style={{ marginLeft: "10px", marginTop: "10px"  }}>
//             <Mics setResponse={setResponse} id="mic2" setkey={setkey} enablemic={enablemic} />
//           </div>
//         </div>

//         <CardLabel>{`${t("PTR_ALT_MOBILE_NUMBER")}`}</CardLabel>
//         <div style={{ display: "flex", flexDirection: "row" }}>
//           <MobileNumber
//             value={alternateNumber}
//             onFocus={() => setenablemic(true)}
//             onBlur={() => setenablemic(false)}
//             name="alternateNumber"
//             onChange={setAltMobileNo}
//             style={inputStyles}
//             {...{ required: false, type: "tel", title: t("CORE_COMMON_APPLICANT_MOBILE_NUMBER_INVALID") }}
//           />
//           <div style={{ display: "flex", marginTop: "10px" }}>
//             <Mics setResponse={setResponse} id="mic3" setkey={setkey} enablemic={enablemic}/>
//           </div>
//         </div>

//         <CardLabel>
//           {`${t("PTR_FATHER_HUSBAND_NAME")}`} <span className="astericColor">*</span>
//         </CardLabel>
//         <div style={{ display: "flex", flexDirection: "row" }}>
//           <TextInput
//             t={t}
//             type={"text"}
//             isMandatory={false}
//             onFocus={() => setenablemic(true)}
//             onBlur={() => setenablemic(false)}
//             optionKey="i18nKey"
//             name="fatherName"
//             style={inputStyles}
//             value={fatherName}
//             onChange={(e) => setFatherOrHusbandName(e.target.value)} // Regular input change handling
//             ValidationRequired={true}
//             {...(validation = {
//               isRequired: true,
//               pattern: "^[a-zA-Z ]+$",
//               type: "tel",
//               title: t("PT_NAME_ERROR_MESSAGE"),
//             })}
//           />
//           <div style={{ display: "flex", marginTop: "10px" }}>
//             <Mics setResponse={setResponse} id="mic4" setkey={setkey} enablemic={enablemic}/>
//           </div>
//         </div>

//         <CardLabel>
//           {`${t("PTR_EMAIL_ID")}`} <span className="astericColor">*</span>
//         </CardLabel>
//         <div style={{ display: "flex", flexDirection: "row" }}>
//           <TextInput
//             t={t}
//             type={"email"}
//             onFocus={() => setenablemic(true)}
//             onBlur={() => setenablemic(false)}
//             isMandatory={true}
//             optionKey="i18nKey"
//             name="emailId"
//             value={emailId}
//             style={inputStyles}
//             onChange={setOwnerEmail}
//             ValidationRequired={true}
//             {...(validation = {
//               isRequired: true,
//               pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z]+\\.[a-zA-Z]{3,4}$",
//               type: "email",
//               title: t("PT_NAME_ERROR_MESSAGE"),
//             })}
//           />
//           <div style={{ display: "flex", marginTop: "10px" }}>
//             <Mics setResponse={setResponse} id="mic5" setkey={setkey} enablemic={enablemic}/>
//           </div>
//         </div>
//       </FormStep>
//     </React.Fragment>
//   );
// };

// export default PTRCitizenDetails;

// import React, { useEffect, useState } from "react";
// import { FormStep, TextInput, CardLabel, MobileNumber } from "@nudmcdgnpm/digit-ui-react-components";
// import Timeline from "../components/PTRTimeline";
// import Mics from "../components/Mic";

// const PTRCitizenDetails = ({ t, config, onSelect, userType, formData, renewApplication }) => {
//   const user = Digit.UserService.getUser().info; // service to fetch user information
//   const inputStyles = { width: user.type === "EMPLOYEE" ? "50%" : "86%" };
//   let validation = {};

//   // added data from renewapplication, renders data if there is data in renewapplication
//   const [response, setResponse] = useState("");
//   const [key, setkey] = useState(0);
//   const [applicantName, setName] = useState(
//     renewApplication?.applicantName || (user.type === "EMPLOYEE" ? "" : user?.name) || formData?.ownerss?.applicantName || ""
//   );
//   const [emailId, setEmail] = useState(renewApplication?.emailId || formData?.ownerss?.emailId || "");
//   const [mobileNumber, setMobileNumber] = useState(
//     renewApplication?.mobileNumber || (user.type === "EMPLOYEE" ? "" : user?.mobileNumber) || formData?.ownerss?.mobileNumber || ""
//   );
//   const [alternateNumber, setAltMobileNumber] = useState(formData?.ownerss?.alternateNumber || "");
//   const [fatherName, setFatherOrHusbandName] = useState(renewApplication?.fatherName || formData?.ownerss?.fatherName || "");
//   console.log("idkey", key);
//   console.log("response", response);

//   function setOwnerName(e) {
//     setName(e.target.value);
//   }

//   function setOwnerEmail(e) {
//     setEmail(e.target.value);
//   }

//   function setMobileNo(e) {
//     // If `e` is a value (not an event), set it directly
//     setMobileNumber(e?.target?.value || e);
//   }

//   function setAltMobileNo(e) {
//     setAltMobileNumber(e?.target?.value || e);
//   }

//   // Automatically set father's name from response if available
//   useEffect(() => {
//     if (response) {
//       switch (key) {
//         case "mic1":
//           setName(response);
//           break;

//         case "mic2":
//           setMobileNo(response.replace(/ /g, ""));
//           break;
//         case "mic3":
//           setAltMobileNo(response.replace(/ /g, ""));
//           break;
//         case "mic4":
//           setFatherOrHusbandName(response);
//           break;
//         case "mic5":
//           setEmail(response);
//           break;

//         default:
//           break;
//       }
//     }
//   }, [response]); // Update whenever response changes

//   const goNext = () => {
//     let owner = formData.ownerss;
//     let ownerStep;
//     if (userType === "citizen") {
//       ownerStep = { ...owner, applicantName, mobileNumber, alternateNumber, fatherName, emailId };
//       onSelect(config.key, { ...formData[config.key], ...ownerStep }, false);
//     } else {
//       ownerStep = { ...owner, applicantName, mobileNumber, alternateNumber, fatherName, emailId };
//       onSelect(config.key, ownerStep, false);
//     }
//   };

//   const onSkip = () => onSelect();

//   useEffect(() => {
//     if (userType === "citizen") {
//       goNext();
//     }
//   }, [applicantName, mobileNumber, fatherName, emailId]);

//   console.log("key sidjfolsdjf ::: ", key);

//   return (
//     <React.Fragment>
//       {<Timeline currentStep={1} />}

//       <FormStep config={config} onSelect={goNext} onSkip={onSkip} t={t} isDisabled={!applicantName || !mobileNumber || !fatherName || !emailId}>
//         <CardLabel>
//           {`${t("PTR_APPLICANT_NAME")}`} <span className="astericColor">*</span>
//         </CardLabel>
//         <div style={{ display: "flex", flexDirection: "row" }}>
//           <TextInput
//             t={t}
//             type={"text"}
//             isMandatory={false}
//             optionKey="i18nKey"
//             name="applicantName"
//             value={applicantName}
//             style={inputStyles}
//             onChange={setOwnerName}
//             ValidationRequired={true}
//             {...(validation = {
//               isRequired: true,
//               pattern: "^[a-zA-Z ]+$",
//               type: "tel",
//               title: t("PT_NAME_ERROR_MESSAGE"),
//             })}
//           />
//           <div style={{ display: "flex", marginTop: "10px" }}>
//             <Mics setResponse={setResponse} id={"mic1"} setkey={setkey} />
//           </div>
//         </div>

//         <CardLabel>
//           {`${t("PTR_MOBILE_NUMBER")}`} <span className="astericColor">*</span>
//         </CardLabel>
//         <div style={{ display: "block" }}>
//           <MobileNumber
//             value={mobileNumber}
//             name="mobileNumber"
//             onChange={setMobileNo}
//             style={{ inputStyles }}
//             {...{ required: true, type: "tel", title: t("CORE_COMMON_APPLICANT_MOBILE_NUMBER_INVALID") }}
//           />
//           <div style={{ marginLeft: "10px", marginTop: "10px"  }}>
//             <Mics setResponse={setResponse} id="mic2" setkey={setkey} />
//           </div>
//         </div>

//         <CardLabel>{`${t("PTR_ALT_MOBILE_NUMBER")}`}</CardLabel>
//         <div style={{ display: "flex", flexDirection: "row" }}>
//           <MobileNumber
//             value={alternateNumber}
//             name="alternateNumber"
//             onChange={setAltMobileNo}
//             style={inputStyles}
//             {...{ required: false, type: "tel", title: t("CORE_COMMON_APPLICANT_MOBILE_NUMBER_INVALID") }}
//           />
//           <div style={{ display: "flex", marginTop: "10px" }}>
//             <Mics setResponse={setResponse} id="mic3" setkey={setkey} />
//           </div>
//         </div>

//         <CardLabel>
//           {`${t("PTR_FATHER_HUSBAND_NAME")}`} <span className="astericColor">*</span>
//         </CardLabel>
//         <div style={{ display: "flex", flexDirection: "row" }}>
//           <TextInput
//             t={t}
//             type={"text"}
//             isMandatory={false}
//             optionKey="i18nKey"
//             name="fatherName"
//             style={inputStyles}
//             value={fatherName}
//             onChange={(e) => setFatherOrHusbandName(e.target.value)} // Regular input change handling
//             ValidationRequired={true}
//             {...(validation = {
//               isRequired: true,
//               pattern: "^[a-zA-Z ]+$",
//               type: "tel",
//               title: t("PT_NAME_ERROR_MESSAGE"),
//             })}
//           />
//           <div style={{ display: "flex", marginTop: "10px" }}>
//             <Mics setResponse={setResponse} id="mic4" setkey={setkey} />
//           </div>
//         </div>

//         <CardLabel>
//           {`${t("PTR_EMAIL_ID")}`} <span className="astericColor">*</span>
//         </CardLabel>
//         <div style={{ display: "flex", flexDirection: "row" }}>
//           <TextInput
//             t={t}
//             type={"email"}
//             isMandatory={true}
//             optionKey="i18nKey"
//             name="emailId"
//             value={emailId}
//             style={inputStyles}
//             onChange={setOwnerEmail}
//             ValidationRequired={true}
//             {...(validation = {
//               isRequired: true,
//               pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z]+\\.[a-zA-Z]{3,4}$",
//               type: "email",
//               title: t("PT_NAME_ERROR_MESSAGE"),
//             })}
//           />
//           <div style={{ display: "flex", marginTop: "10px" }}>
//             <Mics setResponse={setResponse} id="mic5" setkey={setkey} />
//           </div>
//         </div>
//       </FormStep>
//     </React.Fragment>
//   );
// };

// export default PTRCitizenDetails;
