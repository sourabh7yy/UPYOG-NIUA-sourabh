// reducers/employeeFormReducer.js
import { SET_NDC_STEP, UPDATE_NDC_FORM, RESET_NDC_FORM } from "../actions/types";
import _ from "lodash";

const initialState = {
  step: 1,
  // isValid: false,
  formData: {},
};

const NDCFormReducer = (state = initialState, action) => {
  switch (action.type) {
    case UPDATE_NDC_FORM: {
      const { key, value } = action.payload;
      // Deep-merge plain objects so that a later empty emission from FormComposer
      // (e.g. { PropertyDetails: {} }) does not wipe out already-populated fields.
      // Arrays and non-object primitives are always replaced directly.
      if (value !== null && typeof value === "object" && !Array.isArray(value)) {
        return {
          ...state,
          formData: {
            ...state.formData,
            [key]: _.merge({}, state.formData[key], value),
          },
        };
      }
      return {
        ...state,
        formData: {
          ...state.formData,
          [key]: value,
        },
      };
    }
    case SET_NDC_STEP:
      return {
        ...state,
        step: action.payload,
      };
    case RESET_NDC_FORM:
      return initialState; // <-- reset everything
    default:
      return state;
  }
};

export default NDCFormReducer;
