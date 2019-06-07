[@bs.config {jsx: 3}];

let str = React.string;

open SchoolCommunities__IndexTypes;

type editorAction =
  | ShowEditor(option(Community.t))
  | Hidden;

[@react.component]
let make = (~authenticityToken, ~communities, ~courses, ~connections) => {
  let (editorAction, setEditorAction) = React.useState(() => Hidden);
  let (stateConnections, setStateConnections) =
    React.useState(() => connections);
  let (stateCommunities, setStateCommunities) =
    React.useState(() => communities);

  let updateCommunitiesCB = (community, connections) => {
    setStateCommunities(_ =>
      stateCommunities |> Community.updateList(community)
    );
    setStateConnections(_ => connections);
    setEditorAction(_ => Hidden);
  };

  let addCommunityCB = (community, connections) => {
    setStateCommunities(_ => communities |> List.append([community]));
    setStateConnections(_ => connections);
    setEditorAction(_ => Hidden);
  };
  <div className="flex-1 flex flex-col">
    {
      switch (editorAction) {
      | Hidden => React.null
      | ShowEditor(community) =>
        <SchoolAdmin__EditorDrawer
          closeDrawerCB=(() => setEditorAction(_ => Hidden))>
          <SchoolCommunities__Editor
            authenticityToken
            courses
            community
            connections=stateConnections
            addCommunityCB
            updateCommunitiesCB
          />
        </SchoolAdmin__EditorDrawer>
      }
    }
    <div className="flex px-6 py-2 items-center justify-between">
      <button
        onClick={_ => setEditorAction(_ => ShowEditor(None))}
        className="max-w-3xl w-full flex mx-auto items-center justify-center relative bg-gray-200 hover:bg-gray-400 hover:shadow-md border-2 border-dashed p-6 rounded-lg mt-12 cursor-pointer">
        <i className="material-icons"> {"add_circle_outline" |> str} </i>
        <h4 className="font-semibold ml-2"> {"Add New Community" |> str} </h4>
      </button>
    </div>
    <div className="px-6 pb-4 mt-5 flex flex-1">
      <div className="max-w-3xl w-full mx-auto relative">
        {
          stateCommunities
          |> List.map(community =>
               <div
                 key={community |> Community.id}
                 className="flex items-center shadow bg-white rounded-lg mb-4">
                 <div
                   className="course-faculty__list-item flex w-full items-center">
                   <a
                     onClick={
                       _event => {
                         ReactEvent.Mouse.preventDefault(_event);
                         setEditorAction(_ => ShowEditor(Some(community)));
                       }
                     }
                     className="course-faculty__list-item-details flex flex-1 items-center justify-between cursor-pointer py-4 px-4 hover:bg-gray-200">
                     <div className="flex">
                       <div className="text-sm justify-between">
                         <span className="text-black font-semibold">
                           {community |> Community.name |> str}
                         </span>
                       </div>
                     </div>
                   </a>
                   <div>
                     <a
                       href={"/communities/" ++ (community |> Community.id)}
                       className="text-black font-semibold px-4">
                       {"View" |> str}
                     </a>
                   </div>
                 </div>
               </div>
             )
          |> Array.of_list
          |> ReasonReact.array
        }
      </div>
    </div>
  </div>;
};