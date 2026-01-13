
// DIGIT UI ke card related components import
import {
  Card,
  CardHeader,
  CardSubHeader,
  CardText,
  SubmitBar,
} from "@upyog/digit-ui-react-components";

// React import
import React from "react";

/**
 * ESTAssignAstRequiredDoc Component
 * --------------------------------
 * Ye ek informational step hai jo user ko batata hai:
 * - Asset allotment ke liye kaun-kaun se documents mandatory hain
 * - Ye page sirf info ke liye hai (yahan koi input nahi liya jata)
 */

const ESTAssignAstRequiredDoc = ({ t, config, onSelect, userType, formData }) => {
  console.log("Info page props:", { t, config, onSelect, userType, formData });
  

  // 🔹 Go Next Function
  function goNext() {
   onSelect("Documents", {});
}

  return (
    <React.Fragment>
      <Card>
        <CardHeader>{t("MODULE_EST")}</CardHeader>

        <div>
          <CardSubHeader>{t("EST_REQUIRED_DOCUMENTS")}</CardSubHeader>

          <div style={{ marginTop: "16px" }}>
            <CardText className="primaryColor">
              1. Citizen Request Letter (Accepted PDF)
            </CardText>
            <CardText className="primaryColor">
              2. Allotment Letter (Accepted PDF)
            </CardText>
            <CardText className="primaryColor">
              3. Signed Deed (Accepted PDF)
            </CardText>
          </div>
        </div>

        <span style={{ marginTop: "24px", display: "block" }}>
          <SubmitBar label={t("COMMON_NEXT")} onSubmit={goNext} />
        </span>
      </Card>
    </React.Fragment>
  );
};

export default ESTAssignAstRequiredDoc;
