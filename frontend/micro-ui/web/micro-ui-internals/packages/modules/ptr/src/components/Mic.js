import React, { useState, useEffect } from "react";
import { ReactMic } from "react-mic";
import $ from "jquery";

const Mics = ({ setResponse, id, setkey, enablemic }) => {
  const [blobURL, setBlobURL] = useState(null);
  const [record, setRecord] = useState(false);

  // Hide the visualizer canvas on component mount
  useEffect(() => {
    const visualizer = document.querySelector(`#${id} .visualizer`);
    if (visualizer) {
      visualizer.style.display = "none"; // Hide canvas
    }
  }, [id]);

  // Change button appearance to indicate recording has started
  const handleDisplayForStart = () => {
    const startStopBtn = document.querySelector(`#${id} .start-stop-btn`);
    $(startStopBtn).addClass("stop-btn").removeClass("start-btn");
  };

  // Change button appearance to indicate recording has stopped
  const handleDisplayForStop = () => {
    const startStopBtn = document.querySelector(`#${id} .start-stop-btn`);
    $(startStopBtn).addClass("start-btn").removeClass("stop-btn");
  };

  // Start or stop recording based on enablemic prop
  useEffect(() => {
    if (enablemic) {
      startStopRecording();
    } else if (record) {
      setRecord(false); // Stop recording if mic is disabled
      handleDisplayForStop();
    }
  }, [enablemic]);

  // Toggle recording state and update button appearance
  const startStopRecording = () => {
    setkey(id);
    if (record) {
      setRecord(false);
      handleDisplayForStop();
    } else {
      setRecord(true);
      handleDisplayForStart();

      // Set a timeout to stop the recording after 5 seconds
      setTimeout(() => {
        setRecord(false);
        handleDisplayForStop();
      }, 3000); // 5000ms = 5 seconds
    }
  };

  // Log real-time data chunks
  const onData = (recordedBlob) => {
    console.log("Chunk of real-time data: ", recordedBlob);
  };

  // Convert blob to Base64 string
  const blobToBase64 = async (blob) => {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onloadend = () => resolve(reader.result.split(",")[1]); // Extract Base64 without headers
      reader.onerror = (error) => reject(error);
      reader.readAsDataURL(blob);
    });
  };

  // Handle recording stop event
  const onStop = async (recordedBlob) => {
    try {
      console.log("Recorded Blob Details:", recordedBlob);

      // Convert blob to Base64
      const base64Data = await blobToBase64(recordedBlob.blob);
      console.log("Base64 string: ", base64Data);

      // API Request Payload
      const payload = {
        pipelineTasks: [
          {
            taskType: "asr",
            config: {
              language: {
                sourceLanguage: "hi", // Set the source language
              },
              serviceId: "ai4bharat/conformer-hi-gpu--t4", // ASR Service ID
              audioFormat: "webm", // Ensure this matches your recorded format
              samplingRate: 16000,
              postProcessors: ["itn"],
            },
          },
          {
            taskType: "translation",
            config: {
              language: {
                sourceLanguage: "hi", // Hindi
                targetLanguage: "en", // English
              },
              serviceId: "ai4bharat/indictrans-v2-all-gpu--t4", // Translation Service ID
            },
          },
        ],
        inputData: {
          audio: [
            {
              audioContent: base64Data, // Base64 string without headers
            },
          ],
        },
      };

      // POST request
      const response = await fetch("https://dhruva-api.bhashini.gov.in/services/inference/pipeline", {
        method: "POST",
        headers: {
          userID: "", // Replace with actual userID
          ulcaApiKey: "", // Replace with actual ulcaApiKey
          Authorization: "", // Replace with actual token
          "Content-Type": "application/json",
        },
        body: JSON.stringify(payload),
      });

      const data = await response.json();
      setResponse(data?.pipelineResponse[1]?.output[0]?.target);
      console.log("Response data: ", data?.pipelineResponse[1]?.output[0]?.target);

      if (!response.ok) {
        throw new Error(data.message || response.status);
      }
    } catch (error) {
      console.error("Error during upload or processing: ", error);
    }

    // Optional: Handle blob URL after successful upload
    const url = URL.createObjectURL(recordedBlob.blob);
    setBlobURL(url);
    console.log("Blob URL: ", url);
  };

  // Button style for start/stop recording
  const buttonStyle = {
    fontSize: "32px", // Size of the microphone icon
    padding: "0px",
    cursor: "pointer",
    borderRadius: "50%",
    border: "none",
    backgroundColor: "transparent",
    color: "black",
    transition: "all 0.3s ease",
    outline: "none",
  };

  // Microphone Icon (SVG)
  const micIcon = (
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" className="bi bi-mic-fill" viewBox="0 0 16 16">
      <path d="M5 3a3 3 0 0 1 6 0v5a3 3 0 0 1-6 0z" />
      <path d="M3.5 6.5A.5.5 0 0 1 4 7v1a4 4 0 0 0 8 0V7a.5.5 0 0 1 1 0v1a5 5 0 0 1-4.5 4.975V15h3a.5.5 0 0 1 0 1h-7a.5.5 0 0 1 0-1h3v-2.025A5 5 0 0 1 3 8V7a.5.5 0 0 1 .5-.5" />
    </svg>
  );

  // Stop Icon (SVG)
  const stopIcon = (
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="32" height="32">
      <rect x="6" y="6" width="12" height="12" rx="3" fill="red" stroke="black" strokeWidth="2" />
    </svg>
  );

  return (
    <div id={id} className="App">
      <ReactMic
        visualSetting="none" // Disable visualization (no canvas)
        record={record}
        onStop={onStop} // Pass the onStop function to ReactMic
        onData={onData}
      />
      <button onClick={startStopRecording} type="button" style={buttonStyle} className="start-stop-btn start-btn">
        {record ? stopIcon : micIcon}
      </button>
      <br />
    </div>
  );
};

export default Mics;












// import React, { useState, useEffect } from "react";
// import { ReactMic } from "react-mic";
// import $ from "jquery";

// const Mics = ({ setResponse, id, setkey, enablemic }) => {
//   const [blobURL, setBlobURL] = useState(null);
//   const [record, setRecord] = useState(false);

//   useEffect(() => {
//     const visualizer = document.querySelector(`#${id} .visualizer`);
//     if (visualizer) {
//       visualizer.style.display = "none"; // Hide canvas
//     }
//   }, [id]);

//   const handleDisplayForStart = () => {
//     const startStopBtn = document.querySelector(`#${id} .start-stop-btn`);
//     $(startStopBtn).addClass("stop-btn").removeClass("start-btn");
//   };

//   const handleDisplayForStop = () => {
//     const startStopBtn = document.querySelector(`#${id} .start-stop-btn`);
//     $(startStopBtn).addClass("start-btn").removeClass("stop-btn");
//   };

//   useEffect(() => {
//     if(enablemic){
//       startStopRecording();
//     }
//   }, [enablemic]);

//   const startStopRecording = () => {
//     setkey(id);
//     if (record) {
//       setRecord(false);
//       handleDisplayForStop();
//     } else {
//       setRecord(true);
//       handleDisplayForStart();

//       // Set a timeout to stop the recording after 5 seconds
//       setTimeout(() => {
//         setRecord(false);
//         handleDisplayForStop();
//       }, 3000); // 5000ms = 5 seconds
//     }
//   };

//   const onData = (recordedBlob) => {
//     console.log("Chunk of real-time data: ", recordedBlob);
//   };

//   const blobToBase64 = async (blob) => {
//     return new Promise((resolve, reject) => {
//       const reader = new FileReader();
//       reader.onloadend = () => resolve(reader.result.split(",")[1]); // Extract Base64 without headers
//       reader.onerror = (error) => reject(error);
//       reader.readAsDataURL(blob);
//     });
//   };

//   const onStop = async (recordedBlob) => {
//     try {
//       console.log("Recorded Blob Details:", recordedBlob);

//       // Convert blob to Base64
//       const base64Data = await blobToBase64(recordedBlob.blob);
//       console.log("Base64 string: ", base64Data);

//       // API Request Payload
//       const payload = {
//         pipelineTasks: [
//           {
//             taskType: "asr",
//             config: {
//               language: {
//                 sourceLanguage: "hi", // Set the source language
//               },
//               serviceId: "ai4bharat/conformer-hi-gpu--t4", // ASR Service ID
//               audioFormat: "webm", // Ensure this matches your recorded format
//               samplingRate: 16000,
//               "postProcessors": ["itn"]

//             },
//           },
//           {
//             taskType: "translation",
//             config: {
//               language: {
//                 sourceLanguage: "hi", // Hindi
//                 targetLanguage: "en", // English
//               },
//               serviceId: "ai4bharat/indictrans-v2-all-gpu--t4", // Translation Service ID
//             },
//           },
//         ],
//         inputData: {
//           audio: [
//             {
//               audioContent: base64Data, // Base64 string without headers
//             },
//           ],
//         },
//       };

//       // POST request
//       const response = await fetch(
//         "https://dhruva-api.bhashini.gov.in/services/inference/pipeline",
//         {
//           method: "POST",
//           headers: {
//             userID: "", // Replace with actual userID
//             ulcaApiKey: "", // Replace with actual ulcaApiKey
//             Authorization:
//               "", // Replace with actual token
//             "Content-Type": "application/json",
//           },
//           body: JSON.stringify(payload),
//         }
//       );

//       const data = await response.json();
//       setResponse(data?.pipelineResponse[1]?.output[0]?.target);
//       console.log("Response data: ", data?.pipelineResponse[1]?.output[0]?.target);

//       if (!response.ok) {
//         throw new Error(data.message || response.status);
//       }
//     } catch (error) {
//       console.error("Error during upload or processing: ", error);
//     }

//     // Optional: Handle blob URL after successful upload
//     const url = URL.createObjectURL(recordedBlob.blob);
//     setBlobURL(url);
//     console.log("Blob URL: ", url);
//   };

//   const buttonStyle = {
//     fontSize: "32px", // Size of the microphone icon
//     padding: "0px",
//     cursor: "pointer",
//     borderRadius: "50%",
//     border: "none",
//     backgroundColor: "transparent",
//     color: "black",
//     transition: "all 0.3s ease",
//     outline: "none",
//   };

//   // Microphone Icon (SVG)
//   const micIcon = (
//     <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" className="bi bi-mic-fill" viewBox="0 0 16 16">
//       <path d="M5 3a3 3 0 0 1 6 0v5a3 3 0 0 1-6 0z" />
//       <path d="M3.5 6.5A.5.5 0 0 1 4 7v1a4 4 0 0 0 8 0V7a.5.5 0 0 1 1 0v1a5 5 0 0 1-4.5 4.975V15h3a.5.5 0 0 1 0 1h-7a.5.5 0 0 1 0-1h3v-2.025A5 5 0 0 1 3 8V7a.5.5 0 0 1 .5-.5" />
//     </svg>
//   );

//   // Stop Icon (SVG)
//   const stopIcon = (
//     <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="32" height="32">
//       <g fill="currentColor">
//         <rect x="6" y="6" width="12" height="12" />
//       </g>
//     </svg>
//   );

//   return (
//     <div id={id} className="App">
//       <ReactMic
//         visualSetting="none" // Disable visualization (no canvas)
//         record={record}
//         onStop={onStop} // Pass the onStop function to ReactMic
//         onData={onData}
//       />
//       <button
//         onClick={startStopRecording}
//         type="button"
//         style={buttonStyle}
//         // tabindex="0"
//         // onFocus={startStopRecording}
//         className="start-stop-btn start-btn"
//         >

//         {record ? stopIcon : micIcon}
//       </button>
//       <br />
//       {/* <audio src={blobURL} controls /> */}
//     </div>
//   );
// };

// export default Mics;
